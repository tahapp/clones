//
//  AuthenticationViewController.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit
import WebKit
/* this controller will be used to load a webview where we will sign*/
final class AuthenticationViewController: UIViewController,WKNavigationDelegate
{
    private let webView: WKWebView = {
        let prefernces = WKWebpagePreferences()
        prefernces.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefernces
        
        let v = WKWebView(frame: .zero, configuration: config)
        
        
        return v
    }()
    /* this controller must pass back whether user successfult sign in or cancel */
    public var completionHandler: ((Bool)->Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "sign-in"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else {return}
        webView.load(.init(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        webView.frame = view.bounds
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else{return}
        // here where we get the tokens
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else {return}
        /* we will exchange the code for the access tokens
         then there is no point of showing the redirect url because it was used for securoty purposes.
         aft. then to go back to welcomeVC we use popToRootViewController. and call pass the success to self
         completion. now this closure is called on authmanager  */
        //webView.isHidden = true
        AuthManager.shared.exhangeCodeForToken(code: code) { [weak self] success in
           // if success // addition
            //{ /* we do not need to make sure whether success is tru or fasle here. we will send the result to WelcomeVC*/
                DispatchQueue.main.async {
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completionHandler?(success)
                }
               
            //}
           
        }
    }
}
/* https://developer.spotify.com/documentation/web-api/tutorials/code-flow thii is the page to get authentication from*/
