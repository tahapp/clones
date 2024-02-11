//
//  SearchResutlsCategories.swift
//  mySpotify
//
//  Created by ben hussain on 1/18/24.
//

import Foundation

enum EncapsulatedSearchResutlsCategories
{
    case audioTrack(AudioTrack)
    case artist(Artist)
    case album(AlbumInfo)
    case playlist(PlaylistInfo)
}

struct SearchResutlsCategories:Codable
{
    let tracks:SearchedTrack
    let artists:SearchedArtist
    let albums:Searchedalbums
    let playlists:Searchedplaylists
}
struct SearchedTrack:Codable
{
    let items: [AudioTrack]
}

struct SearchedArtist:Codable
{
    let items: [Artist]
}

struct Searchedalbums:Codable
{
    let items:[AlbumInfo]
}

struct Searchedplaylists:Codable
{
    let items: [PlaylistInfo]
}


