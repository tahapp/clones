//
//  SearchResultViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

private struct SearchSection
{
    let title:String
    let results: [EncapsulatedSearchResutlsCategories]
}
protocol SearchresultViewControllerDelegate:AnyObject
{
    func push(encapsulatedResults:EncapsulatedSearchResutlsCategories)
}
final class SearchResultViewController: UITableViewController
{
    
    weak var delegate: SearchresultViewControllerDelegate?
    override init(style: UITableView.Style) 
    {
        super.init(style: style)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private var searchResults = [SearchSection]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identitfier)
        view.backgroundColor = .systemBackground
    }
    
    func update(with results:[EncapsulatedSearchResutlsCategories])
    {
        // track, artist,album,playlist
        /* there are 80 enum cases, 20 for each type. we need to section those up. so instead of section them up in the api caller,
         we will section them up in the specicfied controller,self,. what we need to do to store each 20 cases into one object or 2D array.
         so we created a struct, easier than 2D array, with array property. we then ran filter on results parameter. notice that we ignore
         the associated value because that would make me create four types (track, artist,album,playlist). so we just focused
         on the cases itself so we have one type which is EncapsulatedSearchResutlsCategories. so we ran four filter methods,
         each returning the desired type (case), then we created four instances of SearchSection passing each filter return value to each
         */
        let tracks = results.filter({
            switch $0
            {
            case .audioTrack(_):
                return true
            default:
                return false
            }
        })
       
        let artists = results.filter({
            switch $0
            {
            case .artist(_):
                return true
            default:
                return false
            }
        })
        
        let albums = results.filter({
            switch $0
            {
            case .album(_):
                return true
            default:
                return false
            }
        })
        
        let playlists = results.filter({
            switch $0
            {
            case .playlist(_):
                return true
            default:
                return false
            }
        })
        
        let tracksSection = SearchSection(title: "Tracks", results: tracks)
        let artistsSection = SearchSection(title: "Artisits", results: artists)
        let albumsSection = SearchSection(title: "Albums", results: albums)
        let playlistsSection = SearchSection(title: "Playlist", results: playlists)
        searchResults.append(contentsOf: [tracksSection,artistsSection,albumsSection,playlistsSection])
       
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
    //MARK: - Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        searchResults.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tableSection = searchResults[section]
        return tableSection.results.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identitfier, for: indexPath) as? SearchResultTableViewCell else{
            return UITableViewCell()
        }
        let result = searchResults[indexPath.section].results[indexPath.row]
        switch result
        {
            //audioTrack
            case .audioTrack(let model):
                let url = URL(string: model.album.images.first!.url)
                let audioTrackModel = SearchResultTableViewCellViewModel(title: model.name, imageURL: url)
                cell.configure(with: audioTrackModel)
            //artist
            case .artist(let model):
                if let stringURL = model.images?.first?.url
                {
                    let url = URL(string: stringURL)
                    let artistModel = SearchResultTableViewCellViewModel(title: model.name, imageURL: url)
                    cell.configure(with: artistModel)
                }
            // album
            case .album(let model):
                let url = URL(string: model.images.first!.url)
                let albumModel = SearchResultTableViewCellViewModel(title: model.name, imageURL: url)
                cell.configure(with: albumModel)
            // playlist
            case .playlist(let model):
                let url = URL(string: model.images.first?.url ?? "")
                let playlistModel = SearchResultTableViewCellViewModel(title: model.name, imageURL: url)
                cell.configure(with: playlistModel)
        }
        return cell
       
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = searchResults[section].title
        label.textColor = .black
        label.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 25)
        return label
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.section].results[indexPath.row]
        delegate?.push(encapsulatedResults: result)
        /*this view controller can not push to a navigation stack, so we will let other controller do what this
         controller suppose to do. in another words this controller will delegate( hands-off) its job that it supposed to do but
         can not do it to another controller. so we create a protocol in the controller/view that will hand-off the mission, then create
         a delagte property and call/access methos/properties in the appropraite place. then the reccieving/conforming controller will adopts
         it and do what the other controller could not do it*/

    }
    
}

