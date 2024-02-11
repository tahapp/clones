//
//  TitleHeaderCollectionReusableView.swift
//  mySpotify
//
//  Created by ben hussain on 1/1/24.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView
{
    static let identifier  = "TitleHeaderCollectionReusableView"
    private let title:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        title.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setTitle( _ str: String)
    {
        title.text = str
    }
}
