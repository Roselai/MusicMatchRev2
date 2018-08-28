//
//  YouTubePlayerViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/18/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper



class YouTubePlayerViewController: UIViewController, YTPlayerViewDelegate{
    
    
    @IBOutlet weak var playerView: YTPlayerView!
    
   
    var videoID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.playerView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(loadVideo), name: Notification.Name("Cell Selected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadVideo), name: Notification.Name("Initial Video ID"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadVideoFromPlaylist), name: Notification.Name("Playlist Item Selected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadVideo), name: Notification.Name("Initial Video ID From Playlist"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadVideo), name: Notification.Name("Liked Video Selected"), object: nil)
    }
    

    @objc func loadVideo(_ notification: Notification) {
        videoID = notification.userInfo?[Constants.YouTubeResponseKeys.VideoID] as! String
        
        if videoID != nil {
        
            let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                                  "enablejsapi" : 1]
       self.playerView.load(withVideoId: videoID, playerVars: playerVars)
        }
        
    }
    
    @objc func loadVideoFromPlaylist(_ notification: Notification) {
        videoID = notification.userInfo?[Constants.YouTubeResponseKeys.VideoID] as! String
        
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                              "enablejsapi" : 1]
      self.playerView.load(withVideoId: self.videoID, playerVars: playerVars)
        
      
        
    }
    


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
