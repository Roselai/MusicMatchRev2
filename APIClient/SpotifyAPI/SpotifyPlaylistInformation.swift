//
//  SpotifyPlaylist.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/25/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

struct SpotifyPlaylistInformation {
    
    var id: String
    var name: String
    var thumbnailURLString: String
    var uri: String
    
    init(json:[String: AnyObject]) {
        
        guard
            let id = json["id"] as? String,
            let name = json["name"] as? String,
            let images = json["images"] as? [[String: AnyObject]],
            let firstImage = images.first,
            let thumbnailURLString = firstImage["url"] as? String,
            let uri = json["uri"] as? String else {
                self.id = ""
                self.name = ""
                self.thumbnailURLString = ""
                self.uri = ""
                return
        }
        
        self.id = id
        self.name = name
        self.thumbnailURLString = thumbnailURLString
        self.uri = uri
    }
    
    
    
}
