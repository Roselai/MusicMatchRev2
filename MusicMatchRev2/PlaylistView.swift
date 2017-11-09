//
//  PlaylistView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/18/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import UIKit
import CoreData

class PlaylistView: CoreDataTableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var videoID: String!
    var playlistID: String!
    var accessToken: String!
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    var managedContext: NSManagedObjectContext!
    var video: Video!
    var playlist: Playlist!
    
    //MARK: TableView DataSource Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
            //getVideosFromPlaylist(accessToken: accessToken, playlistID: playlistID)
            
    
    }
    
    func loadFetchedResultsController () {
        managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! CustomTableViewCell
        
        configure(cell, for: indexPath)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        let fetchedVideo = fetchedResultsController?.fetchedObjects![indexPath.row] as! Video
        
        NotificationCenter.default.post(name: NSNotification.Name("Playlist Item Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : fetchedVideo.videoID])
        
        configure(cell, for: indexPath)
    }
    
    func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? CustomTableViewCell else { return }
        
        let video = fetchedResultsController!.object(at: indexPath) as! Video
        
        //TODO: Change placeHolder Image
        var image = #imageLiteral(resourceName: "addIcon")
        var title: String!
        
        if video.thumbnail != nil, video.title != nil {
            
            image = UIImage(data: video.thumbnail! as Data)!
            title = video.title
            
        } else {
            
            if let imagePath = video.thumbnailURL {
                let url = URL(string: imagePath)
                _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: url!, completionHandlerForDownloadImageData: { (imageData, error) in
                    
                    // GUARD - check for error
                    guard error == nil else {
                        print("Error fetching photo data: \(String(describing: error))")
                        return
                    }
                    
                    // GUARD - check for valid data
                    guard let imageData = imageData else {
                        print("No data returned for photo")
                        return
                    }
                    
                    
                    self.persistentContainer.performBackgroundTask() { (context) in
                        video.thumbnail = imageData as NSData?
                        self.saveContext(context: context)
                    }
                    
                    
                    DispatchQueue.main.async {
                        if video.thumbnail != nil{
                            image = UIImage(data: video.thumbnail! as Data)!
                            let title = video.title
                            cell.update(with: image, title: title)
                        }
                        
                    }
                })
            }
        }
        
        
        cell.update(with: image, title: title)
        
        
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
            
            let video = (self.fetchedResultsController?.fetchedObjects![indexPath.row]) as! Video
           
            YoutubeAPI.sharedInstance().deleteVideoFromYTPlaylist(playlistItemID: video.playlistItemID!, accessToken: self.appDelegate.accessToken, completion: {_ in
                if true {
                   
                    NotificationCenter.default.post(name: NSNotification.Name("Video Deleted Status"), object: nil, userInfo: ["message": "Video deleted from playlist"])
                        
                    DispatchQueue.main.async {
                    self.managedContext.delete(video)
                   // self.saveContext(context: self.managedContext)
                        
                        
                    }
                }
            
            })
                
        
          /*  DispatchQueue.main.async {
                self.tableView.reloadData()
            }*/
            completionHandler(true)
            
            }
        
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    
    
    /*func deleteVideoFromYTPlaylist(playlistItemID: String, accessToken: String){
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.AccessToken: accessToken,
                          Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.PlaylistItemID: playlistItemID]
        
        _ = YoutubeAPI.sharedInstance().taskForDELETEMethod(method: method, parameters: parameters as [String : AnyObject]) { (success, error) in
            if error == nil {
                print("video deleted from playlist")
                
                DispatchQueue.main.async {
               
                let playlist = Playlist(context: self.managedContext)
                playlist.removeFromVideos(self.video)
                
                self.saveContext(context: self.managedContext)
               
                }
            } else {
                print("video could not be deleted")
            }
            
        }
    }*/
    
    func getVideosFromPlaylist(accessToken: String, playlist: Playlist){
        
        
        YoutubeAPI.sharedInstance().getVideosFromPlaylist(accessToken: accessToken, playlist: playlist) { (videos, error) in
            
            
            guard error == nil else {
                print("Error fetching playlists")
                return
            }
            if videos != nil {
                print("Successfully retrieved \(String(describing: videos?.count)) videos")
            }
            
            
            
            DispatchQueue.main.async {
                
                if let videosArray = videos {
                    
                    for videoDictionary in videosArray {
                        
                        let title = videoDictionary[Constants.YouTubeResponseKeys.Title]
                        let id = videoDictionary[Constants.YouTubeResponseKeys.PlaylistItemID]
                        let url = videoDictionary[Constants.YouTubeResponseKeys.ThumbnailURL]
                        let videoID = videoDictionary[Constants.YouTubeResponseKeys.VideoID]
                        
                        
                        if self.someEntityExists(id: id!) == false {
                            
                            let video = Video(context: self.managedContext)
                            video.title = title
                            video.thumbnailURL = url
                            video.videoID = videoID
                            video.playlistItemID = id
                            video.addToPlaylists(playlist)
                            
                            self.saveContext(context: self.managedContext)
                        }
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    func saveContext (context: NSManagedObjectContext){
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    func someEntityExists(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "playlistItemID = %@", id)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try! managedContext.count(for: fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return entitiesCount > 0
    }
    
    
}




