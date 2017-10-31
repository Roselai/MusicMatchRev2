//
//  PlaylistView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/18/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import UIKit

class PlaylistView: UITableViewController {
    
    var playlistID: String!
    var videoID: String!
    var accessToken: String!
    let playlistDataSource = YTTableViewDataSource()

    
    //MARK: TableView DataSource Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = playlistDataSource
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let video = playlistDataSource.items[indexPath.row]
        
        
        
        let imageURL = URL(string: video["url"]!)
   
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            
            
            
            if let error = error {
                print("Error downloading picture: \(error)")
            } else {
                // No errors found.
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let title = video["title"]
                        
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
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        videoID = (playlistDataSource.items[indexPath.row])["videoId"]
        NotificationCenter.default.post(name: NSNotification.Name("Playlist Item Selected"), object: nil, userInfo: ["videoID" : videoID])
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let deleteAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
        
    }
    
    func contextualSegueAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (contextAction, sourceView, completionHandler) in
            
            let playlistItemID = (self.playlistDataSource.items[indexPath.row])["id"]
           
            self.deleteVideoFromYTPlaylist(playlistItemID: playlistItemID!, accessToken: self.accessToken!)
            self.playlistDataSource.items.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            completionHandler(true)
            
        }
        
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    
    
    func deleteVideoFromYTPlaylist(playlistItemID: String, accessToken: String){
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.AccessToken: accessToken,
                          Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.PlaylistItemID: playlistItemID]
        
        _ = YoutubeAPI.sharedInstance().taskForDELETEMethod(method: method, parameters: parameters as [String : AnyObject]) { (success, error) in
            if error == nil {
                print("video deleted from playlist")
            } else {
                print("video could not be deleted")
            }
            
        }
    }
    
    func getVideosFromPlaylist(accessToken: String?, playlistID: String?){
        
        YoutubeAPI.sharedInstance().getVideosFromPlaylist(accessToken: accessToken, playlistID: playlistID) { (videos, error) in
            
            guard error == nil else {
                print("Error fetching playlists")
                self.playlistDataSource.items.removeAll()
                return
            }
            if videos != nil {
                print("Successfully retrieved \(String(describing: videos?.count)) videos")
                self.playlistDataSource.items = videos!
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        }
        
    }
    
    
}




