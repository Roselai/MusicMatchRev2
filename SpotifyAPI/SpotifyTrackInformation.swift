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
    
    init(json:[String: AnyObject]) {
        
        
        name = json["name"] as! String
        artists = json["artist"] as! [AnyObject]
    }
    
    
    
}
