//
//  PlaylistViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

final class FeaturedPlaylistViewController: MusicCollectionViewController, HeaderCollectionViewReusableViewDelegate
{
    
    
    let playlist : PlaylistInfo
    private var tracks: [AudioTrack]?
    var isOwner = false
    init(playlist: PlaylistInfo)
    {
        self.playlist = playlist
        super.init(collectionViewLayout: UICollectionViewLayout() )
    }
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    // MARK: - did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        title = playlist.name
       
        APICaller.shared.getPlaylist(id: playlist.id){ [weak self] result in //playlist details
            switch result
            {
            case .success(let playlistDetail):
                self?.tracks = playlistDetail.tracks.items.map{ 
                    return $0.track
                }
                self?.recomendedTrackViewModels = playlistDetail.tracks.items.compactMap{
                    RecomendedTrackViewModel(trackName: $0.track.name, artistName: $0.track.artists.first!.name, coverImage: URL(string: $0.track.album.images.first!.url))
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
        guard let ownerName = playlist.owner.display_name, let str = playlist.images.first?.url
                ,let url = URL(string: str) else
        {

            return UICollectionReusableView()
        }
        let headerModel = CollectionViewHeaderViewViewModel(playlistName: playlist.name,
                                                              onwerName: ownerName,
                                                              playlistCoverImageURL: url)
        Task
        {
            await header.configure(with:headerModel)
        }
        header.delegate = self
        return header
   }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let ac = UIAlertController(title: "choose action", message: "be careful", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "play", style: .default, handler: {[weak self] _ in
            if let track = self?.tracks?[indexPath.row]
            {
                PlaybackPresenter.shared.startPlayback(from: self!, track: track)
            }
        }))
        ac.addAction(UIAlertAction(title: "remove", style: .destructive, handler: {[weak self] _ in
            guard self!.isOwner else{
                print("you are the not the owner of this track")
                return
            }
            if let selectedTrack = self?.tracks?[indexPath.row]
            {
                APICaller.shared.removeTrackFromPlaylist(track: selectedTrack, playlist: self!.playlist) { success in
                    switch success
                    {
                    case true:
                        DispatchQueue.main.async {
                            self?.tracks?.remove(at: indexPath.row)
                            self?.recomendedTrackViewModels.remove(at: indexPath.row)
                            self?.collectionView.deleteItems(at: [indexPath])
                        }
                    case false:
                        print("false")
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac,animated: true)
    }
    
    func headerCollectionViewReusableViewDidTapPlayAll(_ view: HeaderCollectionViewReusableView) 
    {
        PlaybackPresenter.shared.startPlayback(from: self, playlist: tracks)
    }
    
    override func recomendedTrackCollectionViewCell(_ view: RecomendedTrackCollectionViewCell, addTrackUsing gesture: UILongPressGestureRecognizer)
    {
        
       
    }
}
