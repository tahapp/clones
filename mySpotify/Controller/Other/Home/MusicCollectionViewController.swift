//
//  NewAlbum+FeaturedCollectionViewController.swift
//  mySpotify
//
//  Created by ben hussain on 1/1/24.
//

import UIKit

class MusicCollectionViewController: UICollectionViewController,RecomendedTrackCollectionViewCellDelegate
{

    let height:CGFloat = 450
    var recomendedTrackViewModels = [RecomendedTrackViewModel]()
    let identifier = HeaderCollectionViewReusableView.identifier
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    // MARK: - did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewCompositionalLayout { [weak self] section, _ in
            self?.createSectionLayout(index:section)
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(RecomendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecomendedTrackCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionViewReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: identifier)

        
        
        
    }
  
    // MARK: - layout
    private func createSectionLayout(index:Int)->NSCollectionLayoutSection?
    {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        
        //group
        
        // vertical group inside a horizontalgroup
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height/5)), repeatingSubitem: item, count: 1)
      
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        
        // we will providea a header view. you must register one and subclass it like you would do with CollectionViewCell
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size,
                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                    alignment: .top) // location of the header
        ]
        return section
    }
    // MARK: - Delegates
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recomendedTrackViewModels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecomendedTrackCollectionViewCell.identifier, for: indexPath) as? RecomendedTrackCollectionViewCell else {
           print("fail")
            return UICollectionViewCell()
        }
        cell.delegate = self
        let track = recomendedTrackViewModels[indexPath.item]
        Task
        {
            await cell.configure(with:track)
        }
        return cell
        
    }
    func recomendedTrackCollectionViewCell(_ view: RecomendedTrackCollectionViewCell, addTrackUsing gesture: UILongPressGestureRecognizer) {
        
    }
 
}
