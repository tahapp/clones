//
//  UserPlaylist.swift
//  mySpotify
//
//  Created by ben hussain on 1/29/24.
//

import Foundation

struct UserPlaylist: Codable
{
    let items: [UserPlaylistInfo]
}

 struct UserPlaylistInfo:Codable
{
    let id:String
    let images:[ImageAPI]
    let name:String
    let owner:OwnerData
    let tracks: UserTrackInfo
    
}
 struct UserTrackInfo:Codable
{
    let herf:String?
    let total:Int
}
