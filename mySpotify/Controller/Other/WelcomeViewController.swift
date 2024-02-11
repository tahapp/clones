//
//  WelcomeViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

final class WelcomeViewController: UIViewController 
{
    private let signInButton: UIButton = {
        let b = UIButton()
        b.setTitle("sign in", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = .white
        b.sizeToFit()
        
        return b
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Spotify"
        view.backgroundColor = .green
        navigationItem.largeTitleDisplayMode = .automatic
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        view.addSubview(signInButton)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = .init(x: 20,
                                   y: view.height - 50 - view.safeAreaInsets.bottom,
                                   width: view.width - 40
                                   , height: 50)
    }
    
    @objc func didTapSignIn()
    {
        let vc = AuthenticationViewController()
        vc.completionHandler = {[weak self] success in
            DispatchQueue.main.async
            {
                self?.handleSignIn(success:success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success:Bool)
    {
        // log user or yell error
        if success
        {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            {
                if let window = windowScene.windows.first
                {
                    let mainTab = TabBarViewController()
                    UIView.transition(with: window, duration: 0.3,options: .transitionCrossDissolve, animations: {
                        window.rootViewController = mainTab
                    })
                   
                }
            }
        }else
        {
            if AuthManager.Constants.clientSecret.isEmpty
            {
                let message = """
                fail to login because the client secret was omiited for security reasons,if you wish to use thise code, please provide your own client secert in 'AuthManager.Constants.clientSecret'
                
                """
                let ac = UIAlertController(title: "fail to login", message: message
                                           , preferredStyle: .alert)
                ac.addAction(.init(title: "ok", style: .default))
                present(ac,animated: true)
            }
            let ac = UIAlertController(title: "fail to log in", message: "try again", preferredStyle: .alert)
            ac.addAction(.init(title: "ok", style: .default))
            present(ac,animated: true)
        }
    }
}
