//
//  NewReleases.swift
//  mySpotify
//
//  Created by ben hussain on 12/10/23.
//

import Foundation

struct NewReleases: Codable
{
    let albums: Album
}
struct Album:Codable
{
    let items: [AlbumInfo]
}
