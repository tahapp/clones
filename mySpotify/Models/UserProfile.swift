//
//  UserProfile.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation

struct UserProfile: Codable
{
    let country:String
    let displayName:String
    let email:String
    let explicitContent:Content
    let externalUrls:ExternalURL
    let followers:Follower
    let href:String
    let id:String
    var images:[Image]
    let product:String
    let type:String
    let uri:String
    
    enum CodingKeys:String,CodingKey
    {
        case country
        case displayName = "display_name"
        case email
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case product
        case type
        case uri
        
    }
}

struct Content: Codable
{
    let filterEnabled:Bool
    let filterLocked:Bool
    
    enum CodingKeys:String,CodingKey
    {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}

struct ExternalURL: Codable
{
    let spotify: String
}
struct Follower: Codable
{
    let href:String? // you have to check the documentaion on each key, the documentaion said it will be always null, so we must make it optional
    let total:Int
}

struct Image: Codable
{
    var url:String
    let height:Int
    let width:Int
}

