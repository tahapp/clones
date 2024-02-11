//
//  PlayerControlsView.swift
//  mySpotify
//
//  Created by ben hussain on 1/24/24.
//

import UIKit

protocol PlayerControlsViewDelegate:AnyObject
{
    func playerControlsViewBackButton(_ view: PlayerControlsView)
    func playerControlsViewPauseButton(_ view: PlayerControlsView)
    func playerControlsViewForwardButton(_ view: PlayerControlsView)
    func playerControlsViewSlider(_ view: PlayerControlsView, _ value:Float )
}

class PlayerControlsView: UIView
{
    private var isPlaying:Bool = true
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.text = "this will be the name of the song"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel:UILabel = {
        let label = UILabel()
        label.text = "this will be the description"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    private let slider: UISlider = {
        let s = UISlider()
        s.maximumValue = 1.0
        s.value = 0.2
        s.minimumValue = 0.0
        return s
    }()
    
    private let backButton:UIButton = {
        let b = UIButton()
        b.tag = 1
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        b.setImage(image, for: .normal)
        
        return b
    }()
    private let playPauseButton:UIButton = {
        let b = UIButton()
        b.tag = 2
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        b.setImage(image, for: .normal)
        
        return b
    }()
    private let forwardButton:UIButton = {
        let b = UIButton()
        b.tag = 3
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        b.setImage(image, for: .normal)
        
        return b
    }()
    
    weak var delegate: PlayerControlsViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonClicked), for: .touchUpInside)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.addTarget(self, action: #selector(changeVolume), for: .valueChanged)
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(backButton)
        addSubview(playPauseButton)
        addSubview(forwardButton)
        addSubview(slider)
        establishConstraints()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadData(name:String?,subtitle:String?)
    {
        nameLabel.text = name
        subtitleLabel.text = subtitle
    }
   
    @objc func playButtonClicked()
    {
        isPlaying.toggle()
        delegate?.playerControlsViewPauseButton(self)
        let pause = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    @objc func backButtonClicked()
    {
        
        isPlaying.toggle()
        //let pause = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        playPauseButton.setImage(play, for: .normal)
        delegate?.playerControlsViewBackButton(self)
    }
    @objc func forwardButtonClicked()
    {
        isPlaying.toggle()
        delegate?.playerControlsViewForwardButton(self)
        let pause = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45))
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Keys.key), 
                                               object: PlaybackPresenter.shared,
                                               queue: .main, using: { [weak self] notification in
            guard let count = notification.userInfo?[Keys.key] as? Int else
            {
                return
            }
            if count > 1
            {
                self?.playPauseButton.setImage(pause, for: .normal)
            }else
            {
                self?.playPauseButton.setImage(play, for: .normal)
            }
        })
        
        
    }
    
    @objc func changeVolume()
    {
        let value = slider.value
        
        delegate?.playerControlsViewSlider(self,value)
    }
    private func establishConstraints()
    {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor,constant: 5),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor,constant: 5),
            
            slider.leftAnchor.constraint(equalTo: leftAnchor,constant: 30),
            slider.topAnchor.constraint(lessThanOrEqualTo: subtitleLabel.bottomAnchor,constant:50),
            slider.rightAnchor.constraint(equalTo: rightAnchor,constant: -20),
            
            backButton.leftAnchor.constraint(equalTo: leftAnchor,constant: 30),
            backButton.topAnchor.constraint(lessThanOrEqualTo: slider.bottomAnchor,constant:50),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.topAnchor.constraint(lessThanOrEqualTo: slider.bottomAnchor,constant:50),
            
            forwardButton.rightAnchor.constraint(equalTo: rightAnchor,constant: -30),
            forwardButton.topAnchor.constraint(lessThanOrEqualTo: slider.bottomAnchor,constant:50),
            
        ])
    }
}


