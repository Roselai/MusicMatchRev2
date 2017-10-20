//
//  PlaylistViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/10/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit


class PlaylistsViewController: UITableViewController {
    
  
    var youTubePlaylistsArray: [[String:String]] = []
    var localPlaylistsArray: [[String:String]] = []
    var playlistID: String!
    var videoID: String!
    var accessToken: String!
    
    let sections = ["YouTube Playlist(s)", "Local Playlist(s)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
let appDelegate = UIApplication.shared.delegate as! AppDelegate
        accessToken = appDelegate.accessToken
        
        getPlaylistIDs(accessToken: accessToken!)
      
    }

    
    


    //MARK: TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView = UIView()
            headerView.backgroundColor = UIColor.gray
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
        //headerLabel.font = UIFont(name: "Verdana", size: 20)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.textAlignment = .center
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
            return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section]
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return youTubePlaylistsArray.count
        
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell",
                                                 for: indexPath) as! PlaylistCell
        if indexPath.section == 0 {
            
            let  playlist = youTubePlaylistsArray[indexPath.row]
            
            let imageURL = URL(string: playlist["thumbnail"]!)
            
            _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
                if let error = error {
                    print("Error downloading picture: \(error)")
                } else {
                    // No errors found.
                    if let imageData = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            let title = playlist["title"]
                            
                            cell.textLabel?.numberOfLines = 3
                            cell.textLabel?.lineBreakMode = .byWordWrapping
                            
                            cell.update(with: image, title: title)
                        }
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                }
            }
            
        } else {
        //let  playlist = localPlaylistsArray[indexPath.row]
        cell.textLabel?.text = ""
        cell.imageView?.image = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playlistID = youTubePlaylistsArray[indexPath.row]["id"]
        performSegue(withIdentifier: "showPlaylistForID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaylistForID" {
            let destinationViewController = segue.destination as! PlaylistView
            destinationViewController.playlistID = self.playlistID
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let addAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [addAction])
        return swipeConfig
        
    }
    
    func contextualSegueAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        if indexPath.section == 0 {
            playlistID = youTubePlaylistsArray[indexPath.row]["id"]
        }
        
        let action = UIContextualAction(style: .normal, title: "Add") { (contextAction, sourceView, completionHandler) in
            
            YoutubeAPI.sharedInstance().addVideoToPlaylist(accessToken: self.accessToken, playlistID: self.playlistID, videoID: self.videoID)
            
            //print("Added Video to playlist")
            completionHandler(true)
            
        }
        
        action.image = UIImage(named: "addIcon")
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    func getPlaylistIDs (accessToken: String!) {
 
    
        let method = Constants.YouTubeMethod.PlaylistMethod
        
        let parameters = [Constants.YouTubeParameterKeys.Mine : Constants.YoutubeParameterValues.MineValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (result, error) in
            if error == nil {
                
                if let result = result {
                    let playlistsArray = result["items"] as! [[String:Any]]
                    
                    for index in 0 ... playlistsArray.count-1 {
                        
                        let playlistDict = playlistsArray[index] as [String: Any]
                        
                        var playlistDetailsDict : [String: Any] = [:]
                        
                        playlistDetailsDict["id"] = playlistDict["id"] as! String
                        
                        if let playlistSnippetDict = playlistDict["snippet"] as? [String:Any] {
                            
                            playlistDetailsDict["title"] = playlistSnippetDict["title"] as! String
                            playlistDetailsDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! [String: Any])["high"] as! [String: Any])["url"] as! String
                        }
                        
                        
                        self.youTubePlaylistsArray.append(playlistDetailsDict as! [String : String])
                        
                    }
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                    }
                }
                
                
            } else {
                print(error!)
                
            }
        })
        
        
    }
    
   
    
    
    
}
