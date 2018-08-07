//
//  SpotifyPlaylist.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/26/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class SpotifyPlaylist: NSObject {
    
    
    
    var playlists = [SpotifyPlaylistInformation]()
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    func playlistFromResults(results: [[String : AnyObject]]) -> [SpotifyPlaylistInformation] {
        
        // iterate through array of dictionaries, each Playlist is a dictionary
        for playlist in results {
            playlists.append(SpotifyPlaylistInformation(json: playlist))
        }
        
        return playlists
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SpotifyPlaylist {
        struct Singleton {
            static var sharedInstance = SpotifyPlaylist()
        }
        return Singleton.sharedInstance
    }
    
    
}
