//
//  SpotifyPlaylistView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/26/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class SpotifyPlaylistView: UITableViewController {
    
    var spotifyAccessToken: String!
    var playlistID: String!
    
    override func viewDidLoad() {
        
        SpotifyClient.sharedInstance().getCurrentUserID(accessToken: spotifyAccessToken) { (userID, error) in
            if error == nil {
                guard
                    let currentUserID = userID else {
                        return
                }
                
                //Get List of Playlist Tracks
                SpotifyClient.sharedInstance().getPlaylistTracks(accessToken: self.spotifyAccessToken, userID: currentUserID, playlistID: self.playlistID, completionHandlerForGetPlaylistTracks: { (result, error) in
                    if error == nil {
                        print(result)
                    } else {
                        print (error)
                    }
                })
                
            }   else {
                print(error)
            }
            
            
        }
        
    }
    
    
    
}




