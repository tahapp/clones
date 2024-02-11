//
//  ProfileViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit


final class ProfileViewController: UITableViewController 
{
    private var models : [String] = []
    var user : UserProfile!
    var cached = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: "user")
        title = "Profile"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        fetchProfile()
    }
    
    func setupUI(user:  UserProfile?)
    {
        guard let user = user else{return}
        
        models.append("name = \(user.displayName)")
        cacheImage()
        createTableHeader(with: user.images.first?.url)
        tableView.reloadData()
    }
    
    private func cacheImage()
    {
        let isCached = UserDefaults.standard.bool(forKey: "cache")
        
        if !isCached
        {
            
            guard let urlString = user.images.first?.url, let url =  URL(string:urlString) else{
               
                return}
            URLSession.shared.dataTask(with: .init(url: url)) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    
                    return}
               
                let image = UIImage(data: data)
                let imageData = image?.pngData()
                let fileManager = FileManager()
                let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let path = url.appendingPathComponent("profilePicture.jpeg")
                self?.user.images[0].url = path.path
                do
                {
                    try imageData?.write(to: path, options: .atomic)
                }catch
                {
                    print("caching error: \(error.localizedDescription)")
                }
            }.resume()
            
            cached = true
            UserDefaults.standard.setValue(cached, forKey: "cache")
        }
       
        
       
    }
    private func createTableHeader(with string:String?)
    {
        guard let urlString = string, let url =  URL(string:urlString) else{
           
            return}
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let imageData = try? Data(contentsOf: url)
            {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    self?.tableView.tableHeaderView = imageView
                }
            }
        }
       
       
    }
     
    private func fetchProfile()
    {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async
            {
                switch result
                {
                case .success(let model):
                    self?.user = model
                    self?.setupUI(user: self?.user)
                case .failure(let error):
                    let ac = UIAlertController(title: "failure", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(.init(title: "ok", style: .default))
                    self?.present(ac,animated: true)
                }
            }
           
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        var config = UIListContentConfiguration.cell()
        config.text = models[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
}
