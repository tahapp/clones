//
//  AuthManager.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation

/* this class makes sure that user is sign in and sign in hte users 
 1. this class is almost the starting point*/
final class AuthManager
{
    static let shared = AuthManager()
    private var isRefreshingTokenInProgress = false /* because token refreshing is asynchrounous, we will create a wait mechanism
                                                     */
    private init(){} // private because we do not want any instance, this class is singleton
    
    public var signInURL:URL?
    {
        
        let base = "https://accounts.spotify.com/authorize"
        let redirectURL = "https://www.iosacademy.io"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(redirectURL)&show_dialog=true"
        
        return URL(string:string)
    }
    var isSigned:Bool
    {
        return accessToken != nil
    }
    
    private var accessToken:String?
    {
        return UserDefaults.standard.string(forKey: Constants.accessTokenKey)
    }
    private var refershToken:String?
    {
        return UserDefaults.standard.string(forKey: Constants.refreshTokenKey)
    }
    
    private var tokenExpirationDate:Date?
    {
        return UserDefaults.standard.object(forKey: Constants.expirationDate) as? Date
    }
    
    private var shouldRefershToken:Bool
    {
        // it is bad to refresh the token once its expired, we should do it when the 1st token has a little time left
        // make it expires when access token has ten minutes left
        guard let oldTime = tokenExpirationDate else {
            return false
        }
        let current = Date().addingTimeInterval(600)
        
        return current >= oldTime
    }
   
    // MARK: - exchange
    public func exhangeCodeForToken(code:String,completion: @escaping (Bool)->Void)
    {
        //get token
        guard let url = URL(string: Constants.tokenAPIURL) else {return}
        
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "authorization_code"),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "redirect_uri", value: "https://www.iosacademy.io")
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else
        {
            completion(false)
            print("failure to get base 64")
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] localData, _, localError in
            guard let data = localData, localError == nil else {
             
                completion(false)
                return
            }
            
            do{
                /*let json = try JSONSerialization.jsonObject(with: data,options: .fragmentsAllowed) as? Data
                 JSONSerialization turns json data into json object.
                 is ideal place to view the json content to construct a swift struct based on that content*/
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cachetoken(result:result)
                completion(true)
                
            }catch
            {
                print(error.localizedDescription)
                completion(false)
            }
        }.resume()
    }
    // MARK: - refresh
    /*if its time to refresh the token, call refreshifneeded and pass the new token to the completion pararmter */
    private var onRefreshBlocks = [ ((String)->Void) ]()
    public func withValidToken(completion:@escaping (String)->Void)
    {
        guard !isRefreshingTokenInProgress else {
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefershToken
        {
            refreshIfNeeded {[weak self] success in
                if success
                {
                    if  let token = self?.accessToken
                    {
                        completion(token)
                    }
                }
            }
        }else if  let token = accessToken
        {
            completion(token)
        }
    }
    public  func refreshIfNeeded(completion: @escaping (Bool)->Void)
    {
        guard !isRefreshingTokenInProgress else{
            return
        }
                
        guard shouldRefershToken else{
            completion(true)
            return
        }
        guard let _ = self.refershToken else {
            completion(false)
            return
        }
        // refresh token code:
        isRefreshingTokenInProgress = true
        guard let url = URL(string: Constants.tokenAPIURL) else {return}
        
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "refresh_token"),
        URLQueryItem(name: "refresh_token", value: refershToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else
        {
            completion(false)
            print("failure to get base 64")
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] localData, _, localError in
            self?.isRefreshingTokenInProgress = false // it does not matter whether we get back token or we fail, all we want to know is that we do not to work with unfinished token
            guard let data = localData, localError == nil else {
             
                completion(false)
                return
            }
            
            do{
                /*let json = try JSONSerialization.jsonObject(with: data,options: .fragmentsAllowed) as? Data
                 JSONSerialization turns json data into json object.
                 is ideal place to view the json content to construct a swift struct based o that content*/
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cachetoken(result:result)
                completion(true)
                
                
            }catch
            {
                print(error.localizedDescription)
                completion(false)
            }
        }.resume()
        
    }
    func signOut(completion:(Bool)->Void)
    {
        UserDefaults.standard.setValue(nil, forKey: Constants.accessTokenKey)
        UserDefaults.standard.setValue(nil, forKey: Constants.refreshTokenKey)
        UserDefaults.standard.setValue(nil, forKey: Constants.expirationDate)
        
        completion(true)
    }
    private func cachetoken(result:AuthResponse)
    {
        // we will overwrite the old access token ang get the new acces token.
        UserDefaults.standard.setValue(result.access_token, forKey: Constants.accessTokenKey)
        if let refresh_token = result.refresh_token
        {
            // because there maybe no refresh token then we would store nil.
            UserDefaults.standard.setValue(refresh_token, forKey: Constants.refreshTokenKey)
        }
        
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: Constants.expirationDate)
        // saving result.expire_in only save an integer value and not a time. so we used a date instance to convert the 3600 into
        //an actual time that means one hour from now.
    }
    
    struct Constants
    {
        static let clientID = "a3bf8db1bc394e2eac359c4da17ea3e0"
        static let clientSecret = "" // it was omitted for security reasons 
        
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
        static let accessTokenKey = "access token"
        static let refreshTokenKey = "refresh token"
        static let expirationDate = "expirationData"
      
        
    }
}
//AQBppQUxfGXqLAx9ZH1yE0UehSpHbRJGrdWtE8J83YQYNdsYpUu_qRRFa5T6T1UXL5zTZRrn3W7D6tUg9W8r0qtq7SACYnkmwajygIxcY0bLTrTBnKJVGFx7_r5q7DGQWvt_Ve-9XjAoU8ZinPiRjiPSe2HqYb7YloNcmX1uNrVSwy61uJleZsoTgz8fjFXP
//6d243f79424b4d019cd8bc68b78da6ad
