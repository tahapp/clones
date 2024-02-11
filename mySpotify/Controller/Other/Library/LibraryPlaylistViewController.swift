//
//  LibraryPlaylistViewController.swift
//  mySpotify
//
//  Created by ben hussain on 1/27/24.
//

import UIKit

class LibraryPlaylistViewController: UITableViewController {

    private var userPlaylists =  [PlaylistInfo]()
    var selectionHandler: ((PlaylistInfo)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identitfier)
        
        APICaller.shared.getUserPlaylist { [weak self] result in
            switch result
            {
            case .success(let returnedPlaylists):
                self?.userPlaylists = returnedPlaylists
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.showAlert(with: "JSON decoding error", message: error.localizedDescription)
            }
        }
        
       
    }
 
    @objc  func updateUserPlaylistUI()
    {
        
        let ac = UIAlertController(title: "Add", message: "Add playlist to your Library", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "playlist name"
            
        }
        
        
        let action = UIAlertAction(title: "create playlist", style: .default){ _ in
            let text = ac.textFields?.first?.text
            guard let validText = text , !validText.isEmpty else
            {
                
                return
            }
            
            self.createPlaylist(name: validText)
        }
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        ac.addAction(action)
       present(ac, animated: true)
        
        
    }
    private func createPlaylist(name:String?)
    {
        guard let playlistName = name else {return}
        APICaller.shared.createPlaylist(name: playlistName) { result in
            switch result
            {
            case true:
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                }
            case false:print("no")
            }
        }
    }
    private func showAlert(with title:String,message:String,style: UIAlertController.Style = .alert,
                           action: ((UIAlertAction) ->Void)? = nil  )
    {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        ac.addAction(UIAlertAction(title: "ok", style: .default, handler: action))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.userPlaylists.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identitfier, for: indexPath) as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        let p = userPlaylists[indexPath.row]
        if let str = p.images.first?.url, let url = URL(string: str)
        {
            cell.configure(with: SearchResultTableViewCellViewModel(title: p.name, imageURL: url))
        }else
        {
            cell.configure(with: SearchResultTableViewCellViewModel(title: p.name, imageURL: nil))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let user_playlist = userPlaylists[indexPath.row]

        guard selectionHandler == nil else
        {
            // if it's nil then skip this code
            //if it's not nil then it's false do this code
            selectionHandler?(user_playlist)
            if let isPresentedByViewController = presentingViewController
            {
                isPresentedByViewController.dismiss(animated: true)
            }
            
            return
        }
        
        let vc = FeaturedPlaylistViewController(playlist: user_playlist)
        vc.isOwner = true
        present(vc,animated: true)
        
    }
    
   
}
