//
//  SearchedCategories.swift
//  mySpotify
//
//  Created by ben hussain on 1/8/24.
//

import Foundation


struct Categories:Codable
{
    let categories : Item
}

struct Item:Codable
{
    let items: [Category]
}

struct Category:Codable
{
    let icons: [ImageAPI]
    let id:String
    let name:String
}

