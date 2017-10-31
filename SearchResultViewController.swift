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
    
    var searchQueryString: String = ""
    var videosArray: [[String:String]] = []
    var videoID: String!

    
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return videosArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an instance of UITableViewCell, with default appearance
        // Get a new or recycled cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell",
                                                 for: indexPath)
        
        let videoDetails = videosArray[indexPath.row]
        
        let imageURL = URL(string: videoDetails["thumbnail"]!)
        
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            if let error = error {
                print("Error downloading picture: \(error)")
            } else {
                // No errors found.
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let title = videoDetails["title"]
                        
                        cell.textLabel?.numberOfLines = 3
                        cell.textLabel?.lineBreakMode = .byWordWrapping
                        cell.imageView?.image = image
                        cell.textLabel?.text = title
                        
                    }
                } else {
                    print("Couldn't get image: Image is nil")
                }
            }
        }
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        videoID = videosArray[indexPath.row]["videoID"]!
        
        NotificationCenter.default.post(name: NSNotification.Name("Cell Selected"), object: nil, userInfo: ["id" : videoID])
    }
    
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        //self.performSegue(withIdentifier: "showPlaylists", sender: self)
        let segueAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [segueAction])
        return swipeConfig

    }
    
    func contextualSegueAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {

        var video = videosArray[indexPath.row]
        videoID = video["videoID"]
        
        let action = UIContextualAction(style: .normal, title: "Add") { (contextAction, sourceView, completionHandler) in
            
            self.performSegue(withIdentifier: "showPlaylists", sender: self)
            completionHandler(true)
            
        }
       
        action.image = UIImage(named: "addIcon")
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! PlaylistsViewController
        destinationViewController.videoID = self.videoID
    }

    
    func performSearch() {
        let parameters = [Constants.YouTubeParameterKeys.type : Constants.YoutubeParameterValues.typeValue,
                          Constants.YouTubeParameterKeys.Order : Constants.YoutubeParameterValues.orderValue,
                          Constants.YouTubeParameterKeys.MaxResults : "\(Constants.YoutubeParameterValues.ResultLimit)",
            Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
            "q": "\(searchQueryString)"]
        
        let method = Constants.YouTubeMethod.SearchMethod
        
        
        _ =  YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (result, error) in
            
            if error == nil {
                
                
                // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                
                
                let items = result?["items"] as! [[String:AnyObject]]
                
                
                for index in 0 ... items.count-1 {
                    
                    let item = items[index]
                    let snippetDict = item["snippet"] as! [String: AnyObject]
                    
                    var videoDetailsDict : [String: String] = [:]
                    
                    if snippetDict["title"]?.range(of: self.searchQueryString ) != nil {
                        
                        videoDetailsDict["title"] = snippetDict["title"] as? String
                        videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! [String: AnyObject])["high"] as! [String: AnyObject])["url"] as! String?
                        videoDetailsDict["videoID"] = (item["id"] as! [String: AnyObject])["videoId"] as! String?
                        
                        
                        self.videosArray.append(videoDetailsDict)
                        
                    }
                   
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                    }
                }
                
            }
                
            else {
                print(error!)
            }
            
            
        }
    }
    
    
    
    
    
}
