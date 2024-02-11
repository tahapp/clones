//
//  NewReleasesAlbumViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/18/23.
//

import UIKit

final class NewReleasesAlbumViewController: MusicCollectionViewController, HeaderCollectionViewReusableViewDelegate
{
    let album : AlbumInfo
    private var tracks:[AlbumTrackMetaDetails]?
    init(album: AlbumInfo)
    {
        self.album = album
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    required init?(coder: NSCoder) {
       fatalError()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = album.name
        APICaller.shared.getAlbum(id:album.id){ [weak self] result in
            switch result
            {
            case .success(let albumDetail):
                self?.tracks = albumDetail.tracks.items
                self?.recomendedTrackViewModels = albumDetail.tracks.items.compactMap{
                    RecomendedTrackViewModel(trackName: $0.name,
                                             artistName: $0.artists.first!.name,
                                             coverImage: URL(string: albumDetail.images.first!.url))
                }
                DispatchQueue.main.async{
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                           withReuseIdentifier: HeaderCollectionViewReusableView.identifier,
                                                                           for: indexPath) as? HeaderCollectionViewReusableView else {

            return UICollectionReusableView()
        }
        
        guard let ownerName = album.artists.first?.name, let url = URL(string: album.images.first!.url) else
        {

            return UICollectionReusableView()
        }
        let headerModel = CollectionViewHeaderViewViewModel(playlistName: album.name,
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
        if let track = tracks?[indexPath.row]
        {
            let song = AudioTrack(album: album, artists: track.artists, id: track.id, name: track.name, popularity: 0,preview_url: track.preview_url)
            PlaybackPresenter.shared.startPlayback(from: self, track: song)
        }
        
    }
    func headerCollectionViewReusableViewDidTapPlayAll(_ view: HeaderCollectionViewReusableView) {
        let songs = self.tracks?.compactMap{
            AudioTrack(album: self.album, artists: $0.artists, id: $0.id, name: $0.name, popularity: 0, preview_url: $0.preview_url)
        }
        PlaybackPresenter.shared.startPlayback(from: self, playlist: songs)
    }
}
