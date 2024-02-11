//
//  AlbumInfo.swift
//  mySpotify
//
//  Created by ben hussain on 12/18/23.
//

import Foundation

struct AlbumInfo:Codable
{
    let album_type:String
    let id:String
    let images: [ImageAPI]
    let name:String
    let total_tracks:Int
    let release_date:String
    let artists: [Artist]
    
}
