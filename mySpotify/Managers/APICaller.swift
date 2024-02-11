//
//  APICaller.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation

class APICallerInterface
{
    fileprivate init(){}
    var test = false
    func createRequest(with url: URL?,type: HTTPMethod ,completion: @escaping (URLRequest)->Void)
    {
        guard let url = url else {return}
        AuthManager.shared.withValidToken {  token in
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    func performRequest<T:Codable>(request:URLRequest, with model : T.Type, completion: @escaping (Result<T,Error>)->Void)
    {
        
        let task = URLSession.shared.dataTask(with: request) { lowLevelData, response, error in
            guard let middlewareData = lowLevelData, error == nil else
            {
                completion(.failure(APIError.failToGetData))
                
                return
            }
            do
            {
                if self.test
                {
                    
                    let string = try JSONSerialization.jsonObject(with: middlewareData,options: .fragmentsAllowed)
                    print(string)
                }else
                {
                    let highLevelData = try JSONDecoder().decode(T.self, from: middlewareData)
                    completion(.success(highLevelData))
                }
                
            }
            catch DecodingError.keyNotFound(let key, let context) {
                
                print("Key '\(key)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
                
            } catch DecodingError.valueNotFound(let type, let context) {
                print("Value '\(type)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            } catch DecodingError.typeMismatch(let type, let context) {
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            } catch DecodingError.dataCorrupted(let context) {
                print("Data corrupted: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            } 
            catch {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func performPostRequest(baseRequest:URLRequest,jsonDict:[String:Any],completion: @escaping(Bool)->Void)
    {
        var request = baseRequest
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonDict,options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { lowLeveldata, _, error in
            guard let middleLevelData = lowLeveldata, error == nil else
            {
                print("data  == nil ")
                completion(false)
                return
            }
            do{
                
                let highLevelData = try JSONSerialization.jsonObject(with: middleLevelData, options: .fragmentsAllowed)
                
                if let response = highLevelData as? [String:Any],  response["snapshot_id"] as? String != nil
                {
                    
                   completion(true)
                }else
                {
                    print("id  == nil ")
                    completion(false)
                }
            }catch
            {
                print("serialization == nil")
                completion(false)
            }
            
        }
        task.resume()
        
    }
    enum HTTPMethod: String
    {
        case GET
        case POST
        case DELETE
    }
    fileprivate struct Constants
    {
        static let baseAPIURL = "https://api.spotify.com/v1"
        static let newReleases = "https://api.spotify.com/v1/browse/new-releases?limit=5"
        static let featuredPlaylist = "https://api.spotify.com/v1/browse/featured-playlists?country=US&locale=en_US&limit=5"
        static let tracksReco = "https://api.spotify.com/v1/recommendations"
        static let availableGenre = "https://api.spotify.com/v1/recommendations/available-genre-seeds"
        static let searchCategories = "https://api.spotify.com/v1/browse/categories?limit=20"
        static let playlistCategory = "https://api.spotify.com/v1/browse/categories"
        static let search = "https://api.spotify.com/v1/search?"
        static let userPlaylist = "https://api.spotify.com/v1/me/playlists"
                                      
    }
    
    enum APIError:Error
    {
        case failToGetData
    }
}


final class APICaller : APICallerInterface
{
    
    static let shared = APICaller()
    
    private override init() {
        super.init()
    }
    //MARK: - UserProfile
    func getCurrentUserProfile( completion: @escaping (Result<UserProfile,Error>)->Void)
    {
        guard let url = URL(string: Constants.baseAPIURL + "/me") else{
            completion(.failure(APIError.failToGetData))
            return
        }
        createRequest(with: url, type: .GET) {[weak self] request in
            self?.performRequest(request: request, with: UserProfile.self, completion: completion)
        }
    }
    
    // MARK: - NewestReleases
    func getNewestReleases(completion: @escaping (Result<NewReleases,Error>)->Void)
    {
        guard let url = URL(string: Constants.newReleases) else{
            completion(.failure(APIError.failToGetData))
            return
        }
        createRequest(with: url , type: .GET) { [weak self] request in
            self?.performRequest(request: request, with: NewReleases.self, completion: completion)
        }
    }
    
    
    // MARK: - FeaturedPlaylist
    func getFeaturedPlaylist(completion: @escaping (Result<FeaturedPlaylist,Error>)->Void )
    {
        guard let url = URL(string: Constants.featuredPlaylist) else{
            completion(.failure(APIError.failToGetData))
            return
        }
        createRequest(with: url, type: .GET){ [weak self] request in
            self?.performRequest(request: request, with: FeaturedPlaylist.self, completion: completion)
        }
    }
    
    
    // MARK: - TracksRecomendations
    func getTracksRecomendations(genres:[String],completion: @escaping (Result<TracksRecomendations,Error>)->Void )
    {
        let seeds = genres.joined(separator: ",")
        guard let url = URL(string: Constants.tracksReco + "?seed_genres=\(seeds)&limit=20") else{
            completion(.failure(APIError.failToGetData))
            return
        }
        
        createRequest(with: url, type: .GET){ [weak self] request in
            self?.performRequest(request: request, with: TracksRecomendations.self, completion: completion)
        }
    }
    
    //MARK: - Genre
    func getGenreRecomendation(completion: @escaping (Result<Genre,Error>)->Void )
    {
        guard let url = URL(string: Constants.availableGenre) else{
            completion(.failure(APIError.failToGetData))
            return
        }
        createRequest(with: url, type: .GET){ [weak self] request in
            self?.performRequest(request: request, with: Genre.self, completion: completion)
            
        }
    }
  
    // MARK: - Get Album
    func getAlbum(id:String,completion: @escaping (Result<AlbumDetails,Error>)->Void )
    {
        guard let url = URL(string: Constants.baseAPIURL + "/albums/\(id)") else{
            completion(.failure(APIError.failToGetData))
            
            return
        }
        createRequest(with: url, type: .GET){ [weak self] request in
            self?.performRequest(request: request, with: AlbumDetails.self, completion: completion)
        }
    }
    
    // MARK: - Get PlayList
    func getPlaylist(id:String,completion: @escaping (Result<PlaylistDetails,Error>)->Void )
    {
        guard let url = URL(string: Constants.baseAPIURL + "/playlists/\(id)") else{
            completion(.failure(APIError.failToGetData))
            
            return
        }
        createRequest(with: url, type: .GET){ [weak self] request in
            self?.performRequest(request: request, with: PlaylistDetails.self, completion: completion)
            
        }
    }
    // MARK: - searchForCategories
    func getCategories(completion: @escaping (Result<Categories,Error>)->Void)
    {
        guard let searchURL = URL(string:Constants.searchCategories) else
        {
            completion(.failure(APIError.failToGetData))
            return
        }
        
        createRequest(with: searchURL, type: .GET) { [weak self] request in
            
            self?.performRequest(request: request, with: Categories.self, completion: completion)
        }
    }
    
    // MARK: - get categoryPlaylist
    
    func categoryPlaylist(id:String,completion: @escaping (Result<FeaturedPlaylist2,Error>)->Void)
    {
        guard let searchURL = URL(string:Constants.playlistCategory + "/\(id)/playlists?limit=20") else
        {
            completion(.failure(APIError.failToGetData))
            return
        }
        
        createRequest(with: searchURL, type: .GET) { [weak self] request in
            
            self?.performRequest(request: request, with: FeaturedPlaylist2.self, completion: completion)
            
        }
    }
    
   // MARK: - search results
    func search(with query:String,completion: @escaping (Result<[EncapsulatedSearchResutlsCategories],Error>)->Void )
    {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let searchURL = URL(string:Constants.search + "&q=\(encodedQuery)&type=album,artist,playlist,track") else
        {
            completion(.failure(APIError.failToGetData))
            return
        }
        
        createRequest(with: searchURL, type: .GET) {  request in
            //self?.test = true
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failToGetData))
                    
                    return
                }
                do
                {
                    /*let searchData = try JSONDecoder().decode([EncapsulatedSearchResutlsCategories].self, from: data)
                     we are returning an array of [EncapsulatedSearchResutlsCategories] but we are not decodin it we are decoding 'SearchResutlsCategories'.
                     -----
                     /* a beginner mistake is to try to create four cases with associated type of SearchedTrack, SearchedArtist,SearchedAlbum,
                      SearchedPlaylists and append searchData.proerty to the corresponding Enum case. while this is possible it creates
                      a complication. it would cause a long chaain of object access until we reach album,tracks,artisit, and so on. */
                     */
                    
                    let searchData = try JSONDecoder().decode(SearchResutlsCategories.self, from: data)
                   /* let x = searchData.albums.items.compactMap{
                        EncapsulatedSearchResutlsCategories.album($0)
                    } we could do this but this will populate one case and not the other three cases for each searchData.result.items.compactMap variable 
                    as a result we will create one universal array*/
                    var searchResults = [EncapsulatedSearchResutlsCategories]()
                   
                    searchResults.append(contentsOf: searchData.tracks.items.compactMap{
                        EncapsulatedSearchResutlsCategories.audioTrack($0)
                    })
                    searchResults.append(contentsOf: searchData.artists.items.compactMap{
                        EncapsulatedSearchResutlsCategories.artist($0)
                    })
                    searchResults.append(contentsOf: searchData.albums.items.compactMap{
                        EncapsulatedSearchResutlsCategories.album($0)
                    })
                    searchResults.append(contentsOf: searchData.playlists.items.compactMap{
                        EncapsulatedSearchResutlsCategories.playlist($0)
                    })
    
                    completion(.success(searchResults))
               
                }catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                    
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("Value '\(type)' not found: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch DecodingError.dataCorrupted(let context) {
                    print("Data corrupted: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: User Libraray
    func getUserPlaylist(completion: @escaping (Result<[PlaylistInfo],Error>) -> Void)
    {
        guard let url = URL(string:Constants.userPlaylist) else
        {
            completion(.failure(APIError.failToGetData))
            return
        }
        
        createRequest(with: url, type: .GET) {  request in
            //self?.test = true
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failToGetData))
                    
                    return
                }
                do
                {
                    
                    let userData = try JSONDecoder().decode(Playlist.self, from: data)
                    completion(.success(userData.items))
               
                }catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                    
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("Value '\(type)' not found: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch DecodingError.dataCorrupted(let context) {
                    print("Data corrupted: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
       
    }
    
    func createPlaylist(name:String,completion: @escaping(Bool)->Void)
    {
        
        getCurrentUserProfile { [weak self] result in
            switch result
            {
            case .success(let profile):
                let userID = profile.id
                let urlString = "https://api.spotify.com/v1/users/\(userID)/playlists"
                guard let url = URL(string: urlString) else {
                    completion(false)
                    return
                }
               
                self?.createRequest(with: url, type: .POST, completion: { baseRequest in
                    let json : [String:String] =  ["name":name]
                    self?.performPostRequest(baseRequest: baseRequest, jsonDict: json, completion: completion)
                    
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addTrackToPlaylist(track:AudioTrack,playlistID:String,completion: @escaping (Bool)->Void)
    {
        guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks") else
        {
            return
        }

        createRequest(with: url, type: .POST, completion: {[weak self] baseRequest in
            let json = ["uris": ["spotify:track:\(track.id)"]]
                     
            self?.performPostRequest(baseRequest: baseRequest, jsonDict: json, completion: completion)
        })
        
    }
    
    func removeTrackFromPlaylist(track:AudioTrack,playlist:PlaylistInfo,completion: @escaping (Bool)->Void)
    {
                                   
        guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlist.id)/tracks") else
        {
            return
        }
        
        createRequest(with: url, type: .DELETE) { baseRequest in
            let uri = URI(uri: "spotify:track:\(track.id)")
            let json = jsonDataStruct(tracks: [uri], snapshot_id: playlist.snapshot_id)
            //self?.performPostRequest(baseRequest: baseRequest, jsonDict: json, completion: completion)
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let encodedJSON = try? JSONEncoder().encode(json)
            {
                if let secondLevelEncoding = try? JSONSerialization.jsonObject(with: encodedJSON)
                {
                    if let data = try? JSONSerialization.data(withJSONObject: secondLevelEncoding,options: .fragmentsAllowed)
                    {
                        request.httpBody = data
                    }else{print("failed3")}
                }else{print("failed 2")}
            }else{print("failed 1")}
            
            
            let task = URLSession.shared.dataTask(with: request) { lowLeveldata, _, error in
                guard let middleLevelData = lowLeveldata, error == nil else
                {
                    print("data  == nil ")
                    completion(false)
                    return
                }
                do{
                    
                    let highLevelData = try JSONSerialization.jsonObject(with: middleLevelData, options: .fragmentsAllowed)
                    
                    if let response = highLevelData as? [String:Any],  response["snapshot_id"] as? String != nil
                    {
                        
                       completion(true)
                    }else
                    {
                        print("id  == nil ")
                        completion(false)
                    }
                }catch
                {
                    print("serialization == nil")
                    completion(false)
                }
                
            }
            task.resume()
        }
    }
    
}
fileprivate struct jsonDataStruct:Codable
{
    let tracks: [URI]
    let snapshot_id:String
}
fileprivate struct URI:Codable
{
    let uri:String
}
