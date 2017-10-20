//
//  YTPlayerVIewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/9/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper
import GoogleSignIn

class YouTubeSearchController: UIViewController {
    
     fileprivate var searchResultsViewController: SearchResultViewController!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var videoID: String!
    var queryString: String!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let searchController = childViewControllers.first as? SearchResultViewController else  {
            fatalError("Check storyboard for missing SearchResultViewController")
        }
        
        guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
            fatalError("Check storyboard for missing YouTubePlayerViewController")
        }
        
        if queryString != nil {
            searchController.searchQueryString = queryString!
            searchResultsViewController = searchController
            searchResultsViewController.performSearch()
            
            
        }
        
       
        YTPlayerViewController = playerController
        
        
    }
    
}
