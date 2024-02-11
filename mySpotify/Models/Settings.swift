//
//  Settings.swift
//  mySpotify
//
//  Created by ben hussain on 12/10/23.
//

import Foundation

struct Section
{
    let title:String
    let option: [Option]
}
struct Option
{
    let title:String
    let handler: ()->Void
}

