//
//  AuthResponse.swift
//  mySpotify
//
//  Created by ben hussain on 12/7/23.
//

import Foundation

struct AuthResponse: Codable
{
    let access_token:String
    let expires_in: Int
    let refresh_token:String?
    let scope:String
    let token_type:String
}
