//
//  Playlist.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation
struct FeaturedPlaylist2:Codable
{
    let playlists:Playlist
}
struct FeaturedPlaylist:Codable
{
    let playlists:Playlist
}
struct Playlist:Codable
{
    let items: [PlaylistInfo]
}
struct PlaylistInfo:Codable
{
    let id:String
    let images:[ImageAPI]
    let name:String
    let owner:OwnerData
    let snapshot_id:String
    private let tracks: PlaylistTrack
    
}

private struct PlaylistTrack:Codable
{
    let href: String
    let total: Int
          
}
struct OwnerData:Codable
{

    let href:String
    let id:String
    let type:String
    let uri:String
    let display_name:String?
}

//struct PlaylistResponse:Codable
//{
//    let playlists:Playlist
//}
//
//struct Playlist:Codable
//{
//    let href:String
//    let limit:Int
//    let next:String?
//    let offset:Int
//    let previous:String?
//    let total:Int
//    let items:[PlaylistInfo]
//}
//struct PlaylistInfo:Codable
//{
//    let collaborative:Bool
//    let description:String
//    let external_urls:ExternalURLs
//    let href:String
//    let id:String
//    let images:[ImageAPI]
//    let name:String
//    let owner:OwnerData
//    let snapshot_id:String
//    let tracks:TrackInfo
//    let type:String
//    let uri:String
//}
//struct ExternalURLs:Codable
//{
//    let spotify:String
//}
//
//

//
//struct TrackInfo:Codable
//{
//    let href:String
//    let total:Int
//    
//}
