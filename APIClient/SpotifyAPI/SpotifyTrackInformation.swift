//
//  SpotifyTrackInformation.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/27/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

struct SpotifyTrackInformation {
    
    var name: String
    var artists: [AnyObject]
    var albumName: String
    
    init(json:[String: AnyObject]) {
        
        
        guard
            let name = json["name"] as? String,
            let artists = json["artists"] as? [AnyObject],
            let album = json["album"] as? [String:AnyObject],
            let albumName = album["name"] as? String else {
                self.name = ""
                self.artists = []
                self.albumName = ""
                return
        }
        
        
        self.name = name
        self.artists = artists
        self.albumName = albumName
        
        
        
        
    }
    
}
