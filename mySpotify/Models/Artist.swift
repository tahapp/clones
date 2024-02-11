//
//  Artist.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation


struct Artist:Codable
{
    let external_urls:OuterURL
    let id:String
    let images : [ImageAPI]?
    let name:String
    let type:String

}
struct OuterURL:Codable
{
    let spotify:String
}

