//
//  TabBarViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit


final class TabBarViewController: UITabBarController 
{

    override func viewDidLoad() 
    {
        super.viewDidLoad()
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        vc1.tabBarItem = .init(title: "home", image: .init(systemName: "house"), tag: 0)
        vc2.tabBarItem = .init(tabBarSystemItem: .search, tag: 1)
        vc3.tabBarItem = .init(title: "Library", image: .init(systemName: "book"), tag: 2)
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        nav1.navigationBar.prefersLargeTitles = true // if this is false then navigationItem.largeTitleDisplayMode won't work at all
        nav2.navigationBar.prefersLargeTitles = true // if this is true then navigationItem.largeTitleDisplayMode will work depending on the value
        nav3.navigationBar.prefersLargeTitles = true
        
        
        setViewControllers([nav1,nav2,nav3], animated: true)
        selectedIndex = 0
    }
}

