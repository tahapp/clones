//
//  FeaturedPlaylistHeaderCollectionReusableView.swift
//  mySpotify
//
//  Created by ben hussain on 12/25/23.
//

import UIKit

protocol HeaderCollectionViewReusableViewDelegate:AnyObject
{
    func headerCollectionViewReusableViewDidTapPlayAll(_ view: HeaderCollectionViewReusableView)
}

final class HeaderCollectionViewReusableView: UICollectionReusableView {
    static let identifier = "FeaturedPlaylistHeaderCollectionReusableView"
    // MARK: - Properties
    var playButtonIsHiden = false
    private let ownerNameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()

    private let playlistNameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()
    private let playlistCover: UIImageView = {
        let imageView = UIImageView()
        //imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let playButton: UIButton = {
        let b = UIButton()
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))
        b.setImage(image, for: .normal)
        
        return b
    }()
    
    weak var delegate: HeaderCollectionViewReusableViewDelegate?
    // MARK: - init
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        ownerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistCover.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
       // playButton.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        //playButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        addSubview(ownerNameLabel)
        addSubview(playlistNameLabel)
        addSubview(playlistCover)
        addSubview(playButton)
        playButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            ownerNameLabel.topAnchor.constraint(equalTo: topAnchor),
            ownerNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            playlistNameLabel.firstBaselineAnchor.constraint(equalTo: ownerNameLabel.firstBaselineAnchor),
            playlistNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            playlistNameLabel.leadingAnchor.constraint(equalTo: ownerNameLabel.trailingAnchor, constant: 20),
            
            playlistCover.topAnchor.constraint(equalTo: ownerNameLabel.bottomAnchor),
            playlistCover.leadingAnchor.constraint(equalTo: leadingAnchor),
            playlistCover.bottomAnchor.constraint(equalTo: bottomAnchor),
            playlistCover.trailingAnchor.constraint(equalTo: playButton.leadingAnchor),
            
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func didTapPlayAll()
    {
        delegate?.headerCollectionViewReusableViewDidTapPlayAll(self)
    }
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func configure(with viewModel:CollectionViewHeaderViewViewModel) async
    {
        playButton.isHidden = playButtonIsHiden
        ownerNameLabel.text = "owner name = \(viewModel.onwerName)"
        playlistNameLabel.text = "playlist name  \(viewModel.playlistName)"
        if viewModel.playlistCoverImageURL != nil
        {
            do
            {
                let (data,_) =  try  await URLSession.shared.data(from: viewModel.playlistCoverImageURL!)
                playlistCover.image = UIImage(data: data)
            }catch
            {
                print(error.localizedDescription)
            }
            
        }
    }
}



