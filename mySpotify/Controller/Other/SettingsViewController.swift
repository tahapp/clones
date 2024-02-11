//
//  SettingsViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

final class SettingsViewController: UITableViewController {

    private var sections = [Section]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "slot")
        configureModels()
        
    }
    
    // MARK: - User defined
    func configureModels()
    {
        let option = Option(title: "view Profile") 
        {
            [weak self] in
            
            DispatchQueue.main.async
            {
                self?.viewProfile()
            }
                         
        }
        let section = Section(title: "Profile", option: [option])
        
        
        let option2 = Option(title: "Sign Out")
        {
            [weak self] in
            
            DispatchQueue.main.async
            {
                self?.singOut()
            }
                         
        }
        let section2 = Section(title: "Account", option: [option2])
        sections.append(section)
        sections.append(section2)
    }
    private func singOut()
    {
        AuthManager.shared.signOut { success in
            switch success
            {
            case true:
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                {
                    if let window = windowScene.windows.first
                    {
                        let mainTab = WelcomeViewController()
                        
                         let nav = UINavigationController(rootViewController: mainTab)
                         nav.navigationBar.prefersLargeTitles = true
                        UIView.transition(with: window, duration: 0.3,options: .transitionCrossDissolve, animations: {
                            window.rootViewController = nav
                        })
                       
                    }
                }
            case false:
                break
            }
        }
    }
    func viewProfile()
    {
        let vc = ProfileViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    // MARK: - Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].option.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "slot", for: indexPath)
        var config = UIListContentConfiguration.cell()
       
        let model = sections[indexPath.section].option[indexPath.row]
        config.text = model.title
        
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let model = sections[indexPath.section].option[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        model.handler()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let model = sections[section]
        return model.title
        
    }
}
