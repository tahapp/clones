//
//  AudioTrack.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation

struct AudioTrack:Codable
{
    let album:AlbumInfo
    let artists: [Artist]
    let id:String
    let name:String
    let popularity:Int
    let preview_url:String?
    
}

