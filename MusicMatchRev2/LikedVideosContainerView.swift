//
//  LikedVideosContainerView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 6/1/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit

class LikedVideosContainerView: UIViewController {
    
    fileprivate var LikedVideos: LikedVideosView!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var videoID: String!
    var queryString: String!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = ""
        statusLabel.isHidden = true
        
    
        guard let likedVideos = childViewControllers.first as? LikedVideosView  else  {
            fatalError("Check storyboard for missing LikedVideosView")
            
            
            
        }
        
        
        guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
            fatalError("Check storyboard for missing YouTubePlayerViewController")
        }
        

        YTPlayerViewController = playerController
        LikedVideos = likedVideos
        
      
        
    }
  
}
