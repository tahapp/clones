//
//  SearchCollectionViewCell.swift
//  mySpotify
//
//  Created by ben hussain on 1/7/24.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchCollectionViewCell"
    private let title:UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .black

        return label
    }()
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        title.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        contentView.addSubview(title)
        contentView.addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor),
            
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.bottomAnchor.constraint(lessThanOrEqualTo: title.topAnchor),
            
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    private let colors: [UIColor] = [
        .systemRed,
        .systemGreen,
        .systemYellow,
        .systemTeal,
        .systemGray,
        .systemMint,
        .systemGray4,
        .systemPurple
    ]
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        image.image = nil
    }
    func configure( with viewModel:SearchCollectionViewModel)
    {
        title.text = viewModel.name
        
        guard let url = URL(string:viewModel.imageURL) else
        {
            return
        }
        //backgroundColor = colors.randomElement()
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: URLRequest(url:url)) { [weak self]  data, _, error in
                if data != nil
                {
                    let imageToSave = UIImage(data: data!)
                    DispatchQueue.main.async {
                        
                        self?.image.image = imageToSave
                    }
                }
            }.resume()
        }
        
    }
}
