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
    
    @IBOutlet var notificationLabel: UILabel!
    
    fileprivate var playlistView: PlaylistView!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var accessToken: String!
    var playlist: Playlist!
    
    var managedContext: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let playlistController = childViewControllers.first as? PlaylistView else  {
            fatalError("Check storyboard for missing SearchResultViewController")
        }
        
        
        guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
            fatalError("Check storyboard for missing YouTubePlayerViewController")
        }
        
        if accessToken != nil && self.playlist != nil {
            playlistController.accessToken = accessToken
            playlistController.loadFetchedResultsController(playlist: playlist, context: self.managedContext)
            playlistController.getVideosFromPlaylist(accessToken: accessToken, playlist: self.playlist, context: self.managedContext)
        }
        
        playlistController.managedContext = self.managedContext
        
        playlistView = playlistController
        YTPlayerViewController = playerController
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayMessage), name: Notification.Name("Video Deleted Status"), object: nil)
    }
    
    @objc func displayMessage(_ notification: Notification) {
        let message = notification.userInfo?["message"] as! String
        OperationQueue.main.addOperation {
            
            
            self.notificationLabel.text = message
            self.notificationLabel.isHidden = false
            
            
            UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseOut, animations: {
                var labelFrame = self.notificationLabel.frame
                labelFrame.origin.y += (labelFrame.size.height)
                self.notificationLabel.frame = labelFrame
                
            }, completion: { (success) in
                if success == true {
                    self.notificationLabel.isHidden = true
                    
                    var labelFrame = self.notificationLabel.frame
                    labelFrame.origin.y -= (labelFrame.size.height)
                    self.notificationLabel.frame = labelFrame
                    
                }
            })
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

