//
//  RecomendedTrackCollectionViewCell.swift
//  mySpotify
//
//  Created by ben hussain on 12/13/23.
//

import UIKit

protocol RecomendedTrackCollectionViewCellDelegate:AnyObject
{
    func recomendedTrackCollectionViewCell(_ view:RecomendedTrackCollectionViewCell,addTrackUsing gesture:UILongPressGestureRecognizer)
    //func recomendedTrackCollectionViewCell(_ view:UICollectionViewCell,removeTrackUsing gesture:UILongPressGestureRecognizer)
}

final class RecomendedTrackCollectionViewCell: UICollectionViewCell
{
    static let identifier  = "RecomendedTrackCollectionViewCell"
    weak var delegate: RecomendedTrackCollectionViewCellDelegate?
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
//        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var creatorName:String?
    {
        return creatorNameLabel.text
    }
    var songName:String?
    {
        nameLabel.text
    }
    var longGesture : UILongPressGestureRecognizer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(didTapLongGesture))
        contentView.backgroundColor = .secondarySystemBackground
        albumCoverURI.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        creatorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addGestureRecognizer(longGesture)
        contentView.addSubview(albumCoverURI)
        contentView.addSubview(nameLabel)
        contentView.addSubview(creatorNameLabel)
        adjustLayouts()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse() {
        albumCoverURI.image = nil
        nameLabel.text = nil
        creatorNameLabel.text = nil
    }
    @objc func didTapLongGesture(_ gesture:UILongPressGestureRecognizer)
    {
        delegate?.recomendedTrackCollectionViewCell(self, addTrackUsing: gesture)
    }
    private func adjustLayouts()
    {
       
        NSLayoutConstraint.activate([

            albumCoverURI.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            albumCoverURI.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            albumCoverURI.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            albumCoverURI.widthAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor ),
            nameLabel.leadingAnchor.constraint(equalTo: albumCoverURI.trailingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor),
            
            creatorNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 5),
            creatorNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            creatorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor)
            
        ])
    }
    func configure(with viewModel: RecomendedTrackViewModel) async
    {
       
        nameLabel.text = viewModel.trackName
        creatorNameLabel.text = viewModel.artistName
        if viewModel.coverImage != nil
        {
            do
            {
                let (data,_) =  try  await URLSession.shared.data(from: viewModel.coverImage!)
                let imageToSave = UIImage(data: data)

                albumCoverURI.image = imageToSave
            }catch
            {
                print(error.localizedDescription)
            }
            
        }
    }
}
