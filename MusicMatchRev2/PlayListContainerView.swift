//
//  PlayListContainerView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/20/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//



import Foundation
import UIKit
import youtube_ios_player_helper
import GoogleSignIn

class PlaylistContainerView: UIViewController {
    
    fileprivate var playlistView: PlaylistView!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var videoID: String!
    var playlistID: String!
    var accessToken: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let playlistController = childViewControllers.first as? PlaylistView else  {
            fatalError("Check storyboard for missing SearchResultViewController")
        }
        
        
        guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
            fatalError("Check storyboard for missing YouTubePlayerViewController")
        }
        
        if playlistID != nil && accessToken != nil {
            playlistController.playlistID = self.playlistID
            playlistController.accessToken = self.accessToken
            playlistView = playlistController
            playlistController.getVideosFromPlaylist(accessToken: accessToken, playlistID: playlistID)
            
            
        }
        
        
        
        YTPlayerViewController = playerController
    }
        
        
}

