//
//  FeaturedPlaylistCollectionViewCell.swift
//  mySpotify
//
//  Created by ben hussain on 12/13/23.
//

import UIKit

final class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
 
    private let creatorNameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()

    private let nameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return label
    }()
    
    private let albumCoverURI: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        albumCoverURI.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        creatorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(albumCoverURI)
        contentView.addSubview(nameLabel)
        contentView.addSubview(creatorNameLabel)
       
        adjustLayouts()
        
    }
    private func adjustLayouts()
    {
       
        NSLayoutConstraint.activate([
            
            creatorNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor ),
            creatorNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            creatorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: creatorNameLabel.bottomAnchor,constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: creatorNameLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
            
            albumCoverURI.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 5),
            albumCoverURI.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            albumCoverURI.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            albumCoverURI.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
           
        ])
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse() {
        albumCoverURI.image = nil
        nameLabel.text = nil
        creatorNameLabel.text = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistViewModel) async
    {
       
        nameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        if viewModel.uri != nil
        {
            do
            {
                let (data,_) =  try  await URLSession.shared.data(from: viewModel.uri!)
                let imageToSave = UIImage(data: data)
                
                albumCoverURI.image = imageToSave
            }catch
            {
                print(error.localizedDescription)
            }
            
        }
    }
}
