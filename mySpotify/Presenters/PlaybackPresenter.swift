//
//  PlaybackPresenter.swift
//  mySpotify
//
//  Created by ben hussain on 1/24/24.
//


import UIKit
import AVFoundation

private extension NSNotification.Name
{
    static let tracksQueue = NSNotification.Name("queue")
}
struct Keys
{
    static let key = "queue"
}
class PlaybackPresenter: PlaybackPresenterDataSource,PlayerViewControllerDelegate
{
    
    static let shared = PlaybackPresenter()
    private var player:AVPlayer?
    private var track:AudioTrack?
    private var tracks:[AudioTrack] = []
    private var playablePlayerItems : [AVPlayerItem] = []
    private var first = true
    private var playerQueue : AVQueuePlayer!
    
    
    var currentTrack:AudioTrack?
    {
        track
    }
    
    var songName: String?
    {
        track?.name
    }
    
    var subtitle: String?
    {
        track?.artists.first?.name
    }
    
    var imageURL: URL?
    {
        guard let str = currentTrack?.album.images.first?.url else {
            
            return nil}
        return URL(string:str)
    }
   
    
    // MARK: startPlayback
    func startPlayback(from viewController:UIViewController,track:AudioTrack)
    {
        
        self.track = track
        if let trackURL = self.track?.preview_url, let url = URL(string: trackURL)
        {
            self.player = AVPlayer(url: url)
        }else
        {
            HapticsManager.shared.vibrate(of: .error)
            showAlert(from: viewController, with: "preview url", message: "the song does not contains any url to play")
            return
            
        }
        
        let playerViewcontroller = PlayerViewController()
        playerViewcontroller.dataSource = self
        playerViewcontroller.delegate = self
        let navigationPlayerViewController = UINavigationController(rootViewController:playerViewcontroller)
        viewController.present(navigationPlayerViewController, animated: true){ [weak self] in
           
            self?.player?.play()
            self?.player?.volume = 0.2
        }
    }
    
    
    func startPlayback(from viewController:UIViewController,playlist:[AudioTrack]?)
    {
        
        guard let playlists = playlist,playlists.count > 0 else{
            print("nil or empty")
            return
        }
       
        
        for p in playlists
        {
            if p.preview_url != nil
            {
                
                let model = AudioTrack(album: p.album, artists: p.artists, id: p.id, name: p.name, popularity: p.popularity, preview_url: p.preview_url)
                self.tracks.append(model)
            }
            
            
        }
        guard tracks.count > 0 else{
            showAlert(from: viewController, with: "no songs", message: "there are empty songs")
            return}
        self.track = tracks.first

        playablePlayerItems = tracks.map({
            let previewURL = $0.preview_url!
            return AVPlayerItem(url: URL(string: previewURL)!)
        })
        playerQueue = AVQueuePlayer(items: playablePlayerItems)
        NotificationCenter.default.post(name: .tracksQueue, object: self,userInfo: [Keys.key:tracks.count])
//        if let str = track?.preview_url, let url = URL(string: str)
//        {
//            self.player = AVPlayer(url: url)
//        }
        let playerViewcontroller = PlayerViewController()
        playerViewcontroller.dataSource = self
        playerViewcontroller.delegate = self
        let navigationPlayerViewController = UINavigationController(rootViewController:playerViewcontroller)
        viewController.present(navigationPlayerViewController, animated: true)
        { [weak self] in
            
            self?.playerQueue?.play()
            self?.playerQueue?.volume = 0.2
        }
        
       
    }
  
    //MARK: delegates
    func didTapPlayButton(_ viewController: PlayerViewController)
    {
        // if single track, then this code does remove optionality, nothing more 􀆅
        // if tracks with single track, then player will be nil, and we would do as 1st but with playerQueue 􀆅
        // if tracks with multiple tracks, then player will be nil, and we would do as 1st but with playerQueue 􀆅
//        if tracks.count < 2
//        {
            if let player = player
            {
                if player.timeControlStatus == .paused
                {
                    player.play()
                }else if player.timeControlStatus == .playing
                {
                    player.pause()
                }
            }
           
//        }else
        if let queue = playerQueue
        {
        
            if queue.timeControlStatus == .paused
            {
                queue.play()
            }else if queue.timeControlStatus == .playing
            {
                queue.pause()
            }
        }
    
    }
    
    func didTapBackButton(_ viewController: PlayerViewController)
    {
       
        player?.currentItem?.seek(to: .zero,completionHandler: nil)
        player?.pause()
        
        playerQueue?.currentItem?.seek(to: .zero,completionHandler: nil)
        playerQueue?.pause()
        
        
    }
    
    func didTapForwardButton(_ viewController: PlayerViewController)
    {
        
        if tracks.count < 2
        {
            
            player?.currentItem?.seek(to: .zero,completionHandler: nil)
            player?.pause()
            
            playerQueue?.currentItem?.seek(to: .zero,completionHandler: nil)
            playerQueue?.pause()
        }else
        {
            
            
            goToNextSong(viewController)
        }
       
    }
    
    func adjustVolume(_ viewContrller: PlayerViewController, _ value: Float)
    {
        if let player = player
        {
            player.volume = value
            
        }
    }
    
    func didDismissTheViewController()
    {
        player?.pause()
        playerQueue?.pause()
        playerQueue = nil
        player = nil
        track = nil
        tracks.removeAll(keepingCapacity: true)
        playablePlayerItems.removeAll(keepingCapacity: true)
    }
   
    private func goToNextSong(_ controller: PlayerViewController)
    {
        if let currentItem = playerQueue.currentItem
        {
            if let index = playablePlayerItems.firstIndex(of: currentItem)
            {
                if index + 1 == tracks.count // last track in the array
                {
                    showAlert(from: controller, with: "finished", message: "you have reached the last song of the album/playlist"){ [weak self]  _ in
                        self?.didDismissTheViewController()
                        controller.dismiss(animated: true)
                    }
                    return
                }
                self.track = tracks[index + 1]

                Task
                {
                    await controller.updateImage()
                }
                
               
                playerQueue.advanceToNextItem()
                playerQueue.play()
            }
        }
    }
  
    private func showAlert(from viewController:UIViewController,with title:String,message:String,style: UIAlertController.Style = .alert,
                           action: ((UIAlertAction) ->Void)? = nil  )
    {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        ac.addAction(UIAlertAction(title: "ok", style: .default, handler: action))
        viewController.present(ac, animated: true)
    }
}
