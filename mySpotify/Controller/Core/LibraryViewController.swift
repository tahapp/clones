//
//  LibraryViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit


final class LibraryViewController: UIViewController,UIScrollViewDelegate,LibraryToggleViewDelegate
{
    private enum State
    {
        case playlist
        case album
        case none
    }
    private var currentState  = State.none
    private let playlistController = LibraryPlaylistViewController(style: .plain)
    private let albumController = LibraryAlbumViewController(collectionViewLayout: UICollectionViewLayout())
    var isSet = false
    var isScrolledBytoogle = false
    private let toggleView = LibraryToggleView()
    private let scrollView : UIScrollView = {
        let scroll = UIScrollView()
        scroll.layer.borderWidth = 2
        
        scroll.isPagingEnabled = false //
        return scroll
    }()
    
    var scrollViewWidht: CGFloat
    {
        return playlistController.view.bounds.width + albumController.view.bounds.width
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Library"
        scrollView.delegate = self
        navigationController?.navigationBar.backgroundColor = .cyan
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints  = false
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        toggleView.delegate = self
        
        view.addSubview(toggleView)
        view.addSubview(scrollView)
        esablishConstraints()
        
        addChild(albumController)
        scrollView.insertSubview(albumController.view, at: 0)
        
        addChild(playlistController)
        scrollView.insertSubview(playlistController.view, at: 1)
        playlistController.view.frame = .init(x: (albumController.view.bounds.maxX) * 2 , y: 0, width: albumController.view.bounds.width, height: albumController.view.bounds.height)
        // the value of  playlistControllerview.frame sets it offscreen but not problem because it will be only viewd inside the scrollView, and not in a spearate UI 
        playlistController.didMove(toParent: self)
        albumController.didMove(toParent: self)
        
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: playlistController, action: #selector(playlistController.updateUserPlaylistUI))
    }
    private func esablishConstraints()
    {
        NSLayoutConstraint.activate([
            
            toggleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 5),
            toggleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toggleView.widthAnchor.constraint(equalToConstant: 140),
            toggleView.heightAnchor.constraint(equalToConstant: 60),
            
            
            scrollView.topAnchor.constraint(equalTo: toggleView.bottomAnchor,constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
        ])
    }
    
    override func viewDidLayoutSubviews() {
        if !isSet
        {
           
            scrollView.contentSize = .init(width: scrollViewWidht  , height:scrollView.bounds.height)
            isSet = true
        }
        
    }
    func toggleView(_ view: LibraryToggleView,label:String?)
    {
        guard let currentTitle = label else {return}
        if currentTitle == NameConstants.playlist
        {
            isScrolledBytoogle = false
            currentState = .playlist
            scrollView.setContentOffset(.init(x: playlistController.view.width, y: 0), animated: true)
            
        }
        else if currentTitle == NameConstants.album
        {
            isScrolledBytoogle = false
            currentState = .album
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        if isScrolledBytoogle
        {
            if scrollView.contentOffset.x > 700 && scrollView.contentOffset.x < 730
            {
                toggleView.moveToggle(to: .playlist)
                currentState = .playlist
            }else if scrollView.contentOffset.x < 700 && scrollView.contentOffset.x > 670
            {
                
                toggleView.moveToggle(to: .album)
                currentState = .album
            }
        }
     
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) 
    {
        isScrolledBytoogle = true
    }
    
}
