//
//  ViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

enum BrowseSectionType
{
    case featuredPlaylist(viewModels:[FeaturedPlaylistViewModel])
    case newRelease(viewModels:[NewReleaseCellViewModel])
    case recomended(viewModels:[RecomendedTrackViewModel])
    
    var title:String
    {
        switch self
        {
        case .newRelease:
            return "New Releases"
        case .featuredPlaylist:
            return "Featured Playlist"
        case .recomended:
            return "Recomended"
        }
    }
        
}


final class HomeViewController: UICollectionViewController,RecomendedTrackCollectionViewCellDelegate
{
   
    
    var collectionFlowLayout: UICollectionViewFlowLayout
    let height : CGFloat = 450
    private var sections : [BrowseSectionType] = []

    private var newAlbums:[AlbumInfo] = []
    private var featuredPlaylist :[PlaylistInfo] = []
    private var recomendedTracks :[AudioTrack] = []
    // the three above will work as a reference when we click on one of the albums or new releases to display them in separate VC
    
    init()
    {
        collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.scrollDirection = .horizontal
        super.init(collectionViewLayout: collectionFlowLayout)
    }
    required init?(coder: NSCoder)
    {
        collectionFlowLayout = UICollectionViewFlowLayout()
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSetting))
        let layout = UICollectionViewCompositionalLayout { [weak self] section, _ in
            return self?.createSectionLayout(index: section)
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecomendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecomendedTrackCollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        fetchBrowsingData()
    }
   
    //MARK: - API call site
    private func fetchBrowsingData()
    {
        // we want to do aggregrate data, meaning when all the four APIs are done we will assign the data
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleases?
        var playlistResponse: FeaturedPlaylist?
        var trackRecomendation : TracksRecomendations?
        
        APICaller.shared.getNewestReleases{ result in
            defer{
                group.leave()
                
            }
            switch result
            {
            case .failure( _):
                newReleases = nil
                print("new releases failure")
            case .success(let newestRelease):
               newReleases = newestRelease
            }
        }
        
        
       
        APICaller.shared.getFeaturedPlaylist{  result in
            defer{
                group.leave()
                
            }
            switch result
            {
            case .failure( _):
                playlistResponse = nil
                print("featured playlist == nil")
            case .success(let playlist):
                playlistResponse = playlist

            }
        }
        
        
        APICaller.shared.getGenreRecomendation{  result in
           
            switch result
            {
            case .failure( _ ):
                print("Genre failure")
            case .success(let genre):
                let arr = Array(genre.genres[0...4])
                APICaller.shared.getTracksRecomendations(genres: arr){ recomendedResult in
                    defer{
                        group.leave()
                        
                    }
                    switch recomendedResult
                    {
                    case .failure( _):
                        print("recomendationError")
                        trackRecomendation = nil
                    case .success(let track):
                        trackRecomendation = track
                    }
                }
            }
        }
        
        group.notify(queue: .main) // this means that all the four API have done their job
        {
            [weak self] in
            
            guard let albums = newReleases?.albums.items, 
                    let playlists = playlistResponse?.playlists.items,
                    let tracks = trackRecomendation?.tracks else
            {
                
                self?.showAlertViewController(title: "fetch data", message: "fail to decode one of the JSON data")
                return
            }
            self?.configureModels(albums: albums, playlists: playlists, tracks: tracks)
        }
    }
 
    private func configureModels(albums: [AlbumInfo],playlists: [PlaylistInfo],tracks: [AudioTrack])
    {
        self.newAlbums = albums
        self.featuredPlaylist = playlists
        self.recomendedTracks = tracks
        let newReleasesViewModels = albums.compactMap{
            NewReleaseCellViewModel(name: $0.name,
                                    artWorkURL: URL(string:$0.images.first?.url ?? ""),
                                    numberOfTracks: $0.total_tracks,
                                    artisitName: $0.artists.first?.name ?? "no name")
        }
        let featuredPlaylistCellViewModels = playlists.compactMap{
            FeaturedPlaylistViewModel(creatorName:$0.owner.display_name ?? "no name", name: $0.name, uri: URL(string: $0.images.first?.url ?? "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"))
        }
        let recomendedTrackViewModels = tracks.compactMap{
            if let str = $0.album.images.first?.url
            {
                return RecomendedTrackViewModel(trackName: $0.name, artistName: $0.artists.first!.name, coverImage: URL(string: str))
            }else
            {
                return RecomendedTrackViewModel(trackName: $0.name, artistName: $0.artists.first!.name, coverImage: nil)
            }
            
        }
        
        sections.append(.newRelease(viewModels: newReleasesViewModels))
        sections.append(.featuredPlaylist(viewModels: featuredPlaylistCellViewModels))
        sections.append(.recomended(viewModels: recomendedTrackViewModels))
        collectionView.reloadData()
        
        
    }
    @objc func didTapSetting()
    {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - CollectionView
    private func createSectionLayout(index:Int)->NSCollectionLayoutSection?
    {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .absolute(50) ),
                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                    alignment: .top) // location of the header
        ]
        switch index
        {
        case 0:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            //group

            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height/3)), repeatingSubitem: item, count: 3)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(height)), repeatingSubitem: verticalGroup, count: 1)
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            //group
            
            // vertical group inside a horizontalgroup
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(height/2), heightDimension: .absolute(height/2)), repeatingSubitem: item, count: 2)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(height/2), heightDimension: .absolute(height)), repeatingSubitem: verticalGroup, count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            //group
            
            // vertical group inside a horizontalgroup
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height/5)), repeatingSubitem: item, count: 1)
          
            
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            //group
            let group  = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height/3)), repeatingSubitem: item, count: 3)
    
            
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
    //MARK: - Delegates
    override func numberOfSections(in collectionView: UICollectionView) -> Int 
    {
        sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType
        {
        case .featuredPlaylist(viewModels: let featured):
            
            return featured.count
        case .newRelease(viewModels: let newest):
            return newest.count
        case .recomended(viewModels: let recomended):
            return recomended.count
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let type = sections[indexPath.section]
        switch type
        {
            
            case .newRelease(viewModels: let newest):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else
            {
                return UICollectionViewCell()
            }
            let new_release = newest[indexPath.item]
            Task
            {
                await cell.configure(with: new_release)
            }
            
            return cell
            //--------------------------
            case .featuredPlaylist(viewModels: let featured):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else{
                
                return UICollectionViewCell()
                
            }
            let featured_playlist = featured[indexPath.item]
            Task
            {
                await cell.configure(with: featured_playlist)
            }
            
            return cell
            //--------------------------
            case .recomended(viewModels: let recomended):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecomendedTrackCollectionViewCell.identifier, for: indexPath) as? RecomendedTrackCollectionViewCell else
            {
                return UICollectionViewCell()
            }
            let recomended_tracks = recomended[indexPath.item]
            cell.delegate = self
            Task
            {
                await cell.configure(with:recomended_tracks)
            }
            return cell
        
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        switch section
        {
        case .newRelease(viewModels: _):
            let album = newAlbums[indexPath.item]
            let newAlbumViewController = NewReleasesAlbumViewController(album: album)
            navigationController?.pushViewController(newAlbumViewController, animated: true)
        case .featuredPlaylist(viewModels: _):
            let playlist = self.featuredPlaylist[indexPath.item]
            let featuredPlaylistViewController = FeaturedPlaylistViewController(playlist: playlist)
            navigationController?.pushViewController(featuredPlaylistViewController, animated: true)
        case .recomended:
            let track = self.recomendedTracks[indexPath.item]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let titleView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                              withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                                                                              for: indexPath) as? TitleHeaderCollectionReusableView else {return UICollectionReusableView() }
        let section = sections[indexPath.section]

        titleView.setTitle(section.title)
        return titleView
    }
    func recomendedTrackCollectionViewCell(_ view: RecomendedTrackCollectionViewCell, addTrackUsing gesture: UILongPressGestureRecognizer) {
        let selectedTrack = self.recomendedTracks.first(where: {
            $0.name == view.songName && $0.artists.first?.name == view.creatorName
        })
        let ac = UIAlertController(title: view.songName, message: view.creatorName, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "add to playlist", style: .default, handler: { [weak self] action in
            let playlistVC =  LibraryPlaylistViewController()
            
            playlistVC.selectionHandler = {p in
                
                APICaller.shared.addTrackToPlaylist(track: selectedTrack!, playlistID: p.id) { success in //write a note and diagram on how this was implemented
                    switch success
                    {
                    case true:print("yes")
                    case false:print("no")
                    }
                }
            }
            
            self?.present(playlistVC,animated: true)
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac,animated: true)
    }
    private func showAlertViewController(title:String?,message:String?)
    {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .default))
        present(ac,animated: true)
    }
   
}


