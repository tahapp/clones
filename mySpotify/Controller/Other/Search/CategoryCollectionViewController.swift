//
//  CategoryCollectionViewController.swift
//  mySpotify
//
//  Created by ben hussain on 1/9/24.
//

import UIKit



class CategoryCollectionViewController: MusicCollectionViewController
{
    let category : Category
    private var playlists = [PlaylistInfo]()
    init(category: Category)
    {
        self.category = category
        super.init(collectionViewLayout: UICollectionViewLayout() )
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = category.name
    
        APICaller.shared.categoryPlaylist(id: category.id){ [weak self] result in //playlist details
            switch result
            {
            case .success(let playlistsCategory):
                self?.playlists = playlistsCategory.playlists.items
                self?.recomendedTrackViewModels = playlistsCategory.playlists.items.compactMap{
                    RecomendedTrackViewModel(trackName: $0.name, artistName: $0.owner.display_name ?? "no name",
                                             coverImage: URL(string: $0.images.first!.url))
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                           withReuseIdentifier: identifier,
                                                                           for: indexPath) as? HeaderCollectionViewReusableView else {
            
            return UICollectionReusableView()
        }
        guard  let url = URL(string: category.icons.first!.url) else
        {
            
            return UICollectionReusableView()
        }
        let headerModel = CollectionViewHeaderViewViewModel(playlistName: category.name,
                                                            onwerName: category.name,
                                                            playlistCoverImageURL: url)
        header.playButtonIsHiden = true
        Task
        {
            await header.configure(with:headerModel)
        }
       
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let playlist = self.playlists[indexPath.item]
        let vc = FeaturedPlaylistViewController(playlist: playlist)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
