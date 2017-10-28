//
//  File.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/9/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchResultViewController: UITableViewController {
    
    var videoID: String!
    let searchDataSource = YTTableViewDataSource()
 
   

    override func viewDidLoad() {
        super.viewDidLoad()
   
        tableView.dataSource = searchDataSource
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configure(cell, for: indexPath)
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        videoID =  (searchDataSource.items[indexPath.row])[Constants.YouTubeResponseKeys.VideoID]
        
        NotificationCenter.default.post(name: NSNotification.Name("Cell Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : videoID])
        
    }
    
    
    func performSearch(searchQueryString: String) {
        YoutubeAPI.sharedInstance().searchForVideo(searchQuery: searchQueryString) { (videos, error) in
            guard error == nil else {
                print("Error fetching videos")
                self.searchDataSource.items.removeAll()
                return
            }
            if videos != nil {
                print("Successfully retrieved \(String(describing: videos?.count)) videos")
                self.searchDataSource.items = videos!
                
                self.videoID = (videos![0])[Constants.YouTubeResponseKeys.VideoID]
                //send first result videoID to player for load
                NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : self.videoID])
                
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        let video = searchDataSource.items[indexPath.row]
        
        let imageURL = URL(string: video[Constants.YouTubeResponseKeys.ThumbnailURL]!)
        
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            
            
            
            if let error = error {
                print("Error downloading picture: \(error)")
            } else {
                // No errors found.
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let title = video[Constants.YouTubeResponseKeys.Title]
                        
                        if let cell = self.tableView.cellForRow(at: indexPath)
                            as? CustomTableViewCell {
                            
                            cell.update(with: image, title: title)
                        }
                    }
                } else {
                    print("Couldn't get image: Image is nil")
                }
            }
        }
    }
    


    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let segueAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [segueAction])
        return swipeConfig
        
    }
    
    func contextualSegueAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let video = searchDataSource.items[indexPath.row]
        videoID = video[Constants.YouTubeResponseKeys.VideoID]
        
        let action = UIContextualAction(style: .normal, title: "Add") { (contextAction, sourceView, completionHandler) in
            
            //self.performSegue(withIdentifier: "showPlaylists", sender: self)
            
            let title = "Add Video"
            let message = "Select a playlist to add the video to"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let createPlaylistAction = UIAlertAction(title: "Create new playlist", style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "createAPlaylist", sender: self)
            })
            ac.addAction(createPlaylistAction)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let accessToken = appDelegate.accessToken
            
            YoutubeAPI.sharedInstance().fetchUserPlaylists(accessToken: accessToken, completion: { (playlists, error) in
                if error == nil {
                    
                    if let playlists = playlists {
                        
                        for playlist in playlists {
                    
                            let playlistTitle = playlist[Constants.YouTubeResponseKeys.Title]
                            let playlistID = playlist[Constants.YouTubeResponseKeys.PlaylistID]
                            
                            let addAction = UIAlertAction(title: playlistTitle, style: .default ,
                                                          handler: { (action) -> Void in
                                                            
                                                            YoutubeAPI.sharedInstance().addVideoToPlaylist(accessToken: accessToken, playlistID: playlistID, videoID: self.videoID)
                                                            
                            })
                            
                            ac.addAction(addAction)
                        }
                        
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ,
                                             handler: nil)
            ac.addAction(cancelAction)
            self.present(ac, animated: true, completion: nil)
            
            completionHandler(true)
            
        }
        
        action.image = UIImage(named: "addIcon")
        action.backgroundColor = UIColor.black
        return action
        
    }
    
 
    
}
