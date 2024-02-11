//
//  SearchViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit
import SafariServices

class SearchViewController: UICollectionViewController, UISearchBarDelegate, UISearchResultsUpdating,SearchresultViewControllerDelegate
{
    private var categories = [Category]()
    
    let id =  SearchCollectionViewCell.identifier
    init()
    {
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let searchController: UISearchController = {
        let result = SearchResultViewController(style: .grouped)
        let vc = UISearchController(searchResultsController: result)
        vc.searchBar.placeholder = "Songs, Playlist, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        vc.isActive = true
        return vc
    }()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        let layout  = UICollectionViewCompositionalLayout{ _, _ ->NSCollectionLayoutSection  in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
            let group  = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: id)
        
        APICaller.shared.getCategories{result in
            switch result
            {
            case .success(let categories):
                self.categories = categories.categories.items
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
               
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
  }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchItem = searchBar.text, !searchItem.trimmingCharacters(in: .whitespaces).isEmpty else
        {
            
            return
        }
        guard let resultController =  searchController.searchResultsController as? SearchResultViewController else
        {
            return
        }
        resultController.delegate = self
        APICaller.shared.search(with: searchItem) { result in
            
//            for result in results
//            {
                switch result
                {
                case .success(let outcomes):
                    resultController.update(with: outcomes)
                    /* because we will receive four results, album,playlist,artist,track. and we will load different VC based on each
                     result type. however we can't in swift do 'switch class/structtype{case type.instance_property}' unless instance_property is of type
                     the class/struct that was defined in. and only enum cases that are of type of the enum. so we have to encapusalte
                     the search results into one enum type */
                   
                case .failure( _):
                    print("")
                    //print(error.localizedDescription)
                }
//            }
            
                
        }
    }
   
   
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as? SearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        let model = SearchCollectionViewModel(name: category.name, imageURL: category.icons.first!.url)
        cell.configure(with: model)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let categoryKind = categories[indexPath.item]
        let vc = CategoryCollectionViewController(category: categoryKind)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func push(encapsulatedResults: EncapsulatedSearchResutlsCategories) {
        switch encapsulatedResults
        {
        case .audioTrack( let model):
            PlaybackPresenter.shared.startPlayback(from: self, track: model)
        case .artist( let model):
            guard let url = URL(string: model.external_urls.spotify)else
            {
                return
            }
            let safaiVC = SFSafariViewController(url: url)
            present(safaiVC, animated: true)
        case .album(let model):
            print("click3")
            let vc = NewReleasesAlbumViewController(album: model)
            navigationController?.pushViewController(vc, animated: true)
        case .playlist(let model):
            print("click4")
            let vc = FeaturedPlaylistViewController(playlist: model)
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
