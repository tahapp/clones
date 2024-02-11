//
//  PlayerViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

protocol PlayerViewControllerDelegate:AnyObject
{
    func didTapPlayButton(_ viewController:PlayerViewController)
    func didTapBackButton(_ viewController:PlayerViewController)
    func didTapForwardButton(_ viewController:PlayerViewController)
    func adjustVolume(_ viewContrller:PlayerViewController,_ value:Float)
    func didDismissTheViewController()
}

protocol PlaybackPresenterDataSource:AnyObject
{
    var songName:String?{get}
    var subtitle:String? {get}
    var imageURL:URL?{get}
}

final class PlayerViewController: UIViewController,PlayerControlsViewDelegate
{
    private let playerImageView:UIImageView = {
        let displayedImage = UIImageView()
        displayedImage.backgroundColor = .blue
        return displayedImage
    }()

    let controlsView = PlayerControlsView()
    weak var dataSource:PlaybackPresenterDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        
        playerImageView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.delegate = self
        Task
        {
           await self.updateImage()
        }
        
        
        view.addSubview(playerImageView)
        view.addSubview(controlsView)
        NSLayoutConstraint.activate([
            playerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerImageView.heightAnchor.constraint(equalToConstant: view.height / 2),
            playerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            controlsView.topAnchor.constraint(equalTo: playerImageView.bottomAnchor,constant: 10),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
    @objc func didTapClose()
    {
        guard let presenter = presentingViewController else
        {
            return
        }
        delegate?.didDismissTheViewController()
        presenter.dismiss(animated: true)
        
    }
    func updateImage() async
    {
        var picture: UIImage?
        guard let url = dataSource?.imageURL else{
            
            return }
        do{
            let (data, _ ) = try await URLSession.shared.data(from: url)
            picture = UIImage(data: data)
            self.playerImageView.image = picture
            
        }catch
        {
            print(error.localizedDescription)
        }
        controlsView.loadData(name: dataSource?.songName, subtitle: dataSource?.subtitle)
        
    }
    
    @objc private func didTapAction()
    {
        
    }
    
    func playerControlsViewBackButton(_ view: PlayerControlsView) 
    {
        delegate?.didTapBackButton(self)
    }
    
    func playerControlsViewPauseButton(_ view: PlayerControlsView) 
    {
        delegate?.didTapPlayButton(self)
    }
    
    func playerControlsViewForwardButton(_ view: PlayerControlsView) 
    {
        delegate?.didTapForwardButton(self)
    }
  
    func playerControlsViewSlider(_ view: PlayerControlsView, _ value: Float) 
    {
        delegate?.adjustVolume(self, value)
    }
}
