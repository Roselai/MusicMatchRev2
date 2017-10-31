//
//  PlayListContainerView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/20/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//



import Foundation
import UIKit
import CoreData

class PlaylistContainerView: UIViewController {
    
    fileprivate var playlistView: PlaylistView!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var videoID: String!
    var playlistID: String!
    var accessToken: String!
    var playlist: Playlist!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let playlistController = childViewControllers.first as? PlaylistView else  {
            fatalError("Check storyboard for missing SearchResultViewController")
        }
        
        
        guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
            fatalError("Check storyboard for missing YouTubePlayerViewController")
        }
        
        
        guard playlist != nil else {return}
        playlistController.playlist = self.playlist
        
        guard playlistID != nil, accessToken != nil else {return}
        
        playlistController.getVideosFromPlaylist(accessToken: accessToken, playlistID: playlistID)
        playlistView = playlistController
        YTPlayerViewController = playerController
    }
        
        
}

