//
//  PlaylistDetails.swift
//  mySpotify
//
//  Created by ben hussain on 12/18/23.
//

import Foundation

struct PlaylistDetails:Codable
{
    let description:String?
    let id:String
    let images: [ImageAPI]
    let name:String
    let tracks:PlaylistTrackDetails
}

struct PlaylistTrackDetails:Codable
{
    let items: [PlaylistTrackMetaData]
}
struct PlaylistTrackMetaData:Codable
{
    let track: AudioTrack
}
