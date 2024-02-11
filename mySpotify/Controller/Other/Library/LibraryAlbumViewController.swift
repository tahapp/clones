//
//  LibraryAlbumViewController.swift
//  mySpotify
//
//  Created by ben hussain on 1/27/24.
//

import UIKit

class LibraryAlbumViewController: UICollectionViewController {
    
    private var userAlbums =  [AlbumInfo]()
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
   
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
 
    
}
