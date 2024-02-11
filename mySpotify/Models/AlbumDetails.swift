//
//  AlbumDetails.swift
//  mySpotify
//
//  Created by ben hussain on 12/18/23.
//

import Foundation

struct AlbumDetails:Codable
{
    let album_type:String
    let id:String
    let images: [ImageAPI]
    let name:String
    let release_date:String
    let artists: [Artist]
    let tracks : AlbumTrack
}
struct AlbumTrack:Codable
{
 
    let href:String
    let limit:Int
    let next:String?
    let offset:Int
    let previous:String?
    let total:Int
    let items:[AlbumTrackMetaDetails]
}
struct AlbumTrackMetaDetails:Codable
{
    let artists: [Artist]
    let disc_number:Int
    let duration_ms:Int
    let explicit:Bool
    let href:String
    let id:String
    let is_playable:Bool?
    let name:String
    let preview_url:String?
    let track_number:Int
    
}
