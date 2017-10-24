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
    var videosArray: [[String:String]] = []

    
    //MARK: TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return videosArray.count
        
        
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell",
                                                 for: indexPath)
        
        let video = videosArray[indexPath.row]
        
        let imageURL = URL(string: video["thumbnail"]!)
        
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            if let error = error {
                print("Error downloading picture: \(error)")
            } else {
                // No errors found.
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let title = video["title"]
                        
                        cell.textLabel?.numberOfLines = 3
                        cell.textLabel?.lineBreakMode = .byWordWrapping
                        cell.textLabel?.text = title
                        cell.imageView?.image = image
                    }
                } else {
                    print("Couldn't get image: Image is nil")
                }
            }
        }
        return cell
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        videoID = videosArray[indexPath.row]["videoID"]
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
            
            let playlistItemID = self.videosArray[indexPath.row]["playlistItemID"]
           
            self.deleteVideoFromYTPlaylist(playlistItemID: playlistItemID!, accessToken: self.accessToken!)
            self.videosArray.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            completionHandler(true)
            
        }
        
        //action.image = UIImage(named: "addIcon")
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    
    
    
    func getVideosFromPlaylist(accessToken: String?, playlistID: String) {
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken!,
                          Constants.YouTubeParameterKeys.PlaylistID: playlistID,
                          Constants.YouTubeParameterKeys.MaxResults : "50"]
        
       _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (result, error) in
            
            if error == nil {
                if let result = result {
                    let videosArray = result["items"] as! [[String:Any]]
                    
                    for index in 0 ... videosArray.count-1 {
                        
                        let videoDict = videosArray[index] as [String: Any]
                        var videoDetailsDict : [String: Any] = [:]
                        
                        
                        if let videoSnippetDict = videoDict["snippet"] as? [String:Any] {
                            videoDetailsDict["videoID"] = (videoSnippetDict["resourceId"] as! [String:Any])["videoId"] as! String
                            videoDetailsDict["title"] = videoSnippetDict["title"] as! String
                            videoDetailsDict["thumbnail"] = ((videoSnippetDict["thumbnails"] as! [String: Any])["high"] as! [String: Any])["url"] as! String
                        }
                        
           
                            videoDetailsDict["playlistItemID"] = videoDict["id"] as! String
                        
                        
                        self.videosArray.append(videoDetailsDict as! [String : String])
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            } else {
                print(error?.localizedDescription)
            }
            
        }
 
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
    
    
}




