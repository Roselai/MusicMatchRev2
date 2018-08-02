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
        
        id = json["id"] as! String
        name = json["name"] as! String
        
        let images = json["images"] as! [[String: AnyObject]]
        let firstImage = images.first!
        thumbnailURLString = firstImage["url"] as! String
        
        uri = json["uri"] as! String
    }
    
    
    
}
