//
//  SpotifyTrack.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/27/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class SpotifyTrack: NSObject {
    
    
    
    var tracks = [SpotifyTrackInformation]()
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    func trackFromResults(results: [[String : AnyObject]]) -> [SpotifyTrackInformation] {
        
        // iterate through array of dictionaries, each Track is a dictionary
        for track in results {
            tracks.append(SpotifyTrackInformation(json: track))
        }
        
        return tracks
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SpotifyTrack {
        struct Singleton {
            static var sharedInstance = SpotifyTrack()
        }
        return Singleton.sharedInstance
    }
    
    
}

