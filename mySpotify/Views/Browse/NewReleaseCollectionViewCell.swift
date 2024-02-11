//
//  NewReleaseCollectionViewCell.swift
//  mySpotify
//
//  Created by ben hussain on 12/13/23.
//

import UIKit

final class NewReleaseCollectionViewCell: UICollectionViewCell 
{
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumCover: UIImageView = {
        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let albumNameLabel:UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()
    private let artisitNameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()
    
    private let numberOfTracksLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        albumCover.translatesAutoresizingMaskIntoConstraints = false
        albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artisitNameLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(albumCover)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.addSubview(artisitNameLabel)
        adjustLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        albumCover.image = nil
        numberOfTracksLabel.text = nil
        artisitNameLabel.text = nil
    }
    private func adjustLayouts()
    {
       
        NSLayoutConstraint.activate([
            albumCover.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            albumCover.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            albumCover.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            albumCover.widthAnchor.constraint(equalToConstant: 190),
            
            albumNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor ),
            albumNameLabel.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor,constant: 10),
            albumNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
            
            artisitNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor,constant: 5),
            artisitNameLabel.leadingAnchor.constraint(equalTo: albumNameLabel.leadingAnchor),
            artisitNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
           
            numberOfTracksLabel.topAnchor.constraint(equalTo: artisitNameLabel.bottomAnchor,constant: 10),
            numberOfTracksLabel.leadingAnchor.constraint(equalTo: albumNameLabel.leadingAnchor),
            numberOfTracksLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
            
        ])
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        albumNameLabel.sizeToFit()
//        artisitNameLabel.sizeToFit()
//        numberOfTracksLabel.sizeToFit()
//        
//        let imageSize: CGFloat = contentView.height - 10
//        albumCover.frame = .init(x: 5, y: 5, width: imageSize, height: imageSize)
//    }
    
    func configure(with newReleasesModel:NewReleaseCellViewModel) async
    {
        albumNameLabel.text = newReleasesModel.name
        artisitNameLabel.text = newReleasesModel.artisitName
        numberOfTracksLabel.text = newReleasesModel.numberOfTracks.description
        if newReleasesModel.artWorkURL != nil
        {
            do
            {
                let (data,_) =  try  await URLSession.shared.data(from: newReleasesModel.artWorkURL!)
                let imageToSave = UIImage(data: data)
                
                albumCover.image = imageToSave
            }catch
            {
                print(error.localizedDescription)
            }
            
        }
        
        
    }
}
