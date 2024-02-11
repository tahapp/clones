//
//  LibraryToggleView.swift
//  mySpotify
//
//  Created by ben hussain on 1/28/24.
//

import UIKit
protocol LibraryToggleViewDelegate:AnyObject
{
    func toggleView(_ view:LibraryToggleView,label:String?)
}
struct NameConstants
{
    static let playlist = "playlist"
    static let album = "album"
}
class LibraryToggleView: UIView
{

    
    weak var delegate : LibraryToggleViewDelegate?
    private let playlist:UIButton = {
        let b = UIButton(frame: .init(x: 70, y: 0, width: 70, height: 40))
        b.setTitle("playlist", for: .normal)
        b.setTitleColor(.label, for: .normal)
        
        return b
    }()
    
    private let album:UIButton = {
        
        let b = UIButton(frame: .init(x: 0, y: 0, width: 70, height: 40))
        b.setTitle("album", for: .normal)
        b.setTitleColor(.label, for: .normal)
        
        return b
    }()
    
    private let indicator:UIView = {
        let v = UIView(frame: .init(x: 10, y: 41, width: 50, height: 4))
        v.backgroundColor = .red
        return v
    }()
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        playlist.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        album.addTarget(self, action: #selector(didTapAlbum), for: .touchUpInside)
        addSubview(indicator)
        addSubview(playlist)
        addSubview(album)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    @objc private func didTapPlaylist()
    {
        
        
        indicator.frame = .init(x: 70, y: 41, width: 65, height: 4)
        delegate?.toggleView(self,label: playlist.currentTitle)
    }
    @objc private func didTapAlbum()
    {
        indicator.frame = .init(x: 10, y: 41, width: 50, height: 4)
        delegate?.toggleView(self,label: album.currentTitle)
    }
    
    func moveToggle(to state:ToggleState)
    {
        switch state
        {
        case .album:
            indicator.frame = .init(x: 10, y: 41, width: 50, height: 4)
        case .playlist:
            indicator.frame = .init(x: 70, y: 41, width: 65, height: 4)
        }
    }
}
enum ToggleState
{
    case playlist
    case album
}
