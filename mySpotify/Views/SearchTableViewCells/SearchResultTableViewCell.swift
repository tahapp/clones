//
//  SearchResultTableViewCell.swift
//  mySpotify
//
//  Created by ben hussain on 1/23/24.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell 
{
    static let identitfier = "SearchResultTableViewCell"
    private let label : UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
    private let cellImage:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(cellImage)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        cellImage.image = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cellImage.frame = .init(x: 10, y: 0, width: contentView.height, height: contentView.height)
        label.frame = .init(x: cellImage.frame.maxX + 10, y: 0, width: contentView.width, height: contentView.height)
    }
    
    func configure(with viewModel: SearchResultTableViewCellViewModel)
    {
        label.text = viewModel.title
        guard let url = viewModel.imageURL else
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
                        self?.cellImage.image = imageToSave
                    }
                }
            }.resume()
        }
    }
}
