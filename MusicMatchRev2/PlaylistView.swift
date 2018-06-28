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
 
    
    
    //MARK: TableView DataSource Methods
    
   
    
    func loadFetchedResultsController (playlist: Playlist!, context: NSManagedObjectContext) {
       
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "playlist = %@", playlist)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        
        let fetchedVideos = self.fetchedResultsController?.fetchedObjects as! [Video]
        videoID = fetchedVideos.first?.videoID
        //send first result videoID to player for load
        
       
      //  NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID From Playlist"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : self.videoID!])
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! CustomTableViewCell
        
        configure(cell, for: indexPath)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        self.video = fetchedResultsController?.fetchedObjects![indexPath.row] as! Video
        
        NotificationCenter.default.post(name: NSNotification.Name("Playlist Item Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : video.videoID!])
        
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
                _ = APIClient.sharedInstance().downloadimageData(photoURL: url!, completionHandlerForDownloadImageData: { (imageData, error) in
                    
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
            
            APIClient.sharedInstance().deleteVideoFromYTPlaylist(playlistItemID: video.playlistItemID!, accessToken: self.accessToken, completion: { (success) in
            
                if success == true {
                   
                    NotificationCenter.default.post(name: NSNotification.Name("Video Deleted Status"), object: nil, userInfo: ["message": "Video deleted from playlist"])
                        
                    DispatchQueue.main.async {
                        
                            self.managedContext.delete(video)
                            self.saveContext(context: self.managedContext)
                        
                   
                        
                        
                    }
                }
            
            })
            
            completionHandler(true)
            
            }
        
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    
    
   
    
    func getVideosFromPlaylist(accessToken: String, playlist: Playlist, context: NSManagedObjectContext){
        
        APIClient.sharedInstance().getVideosFromPlaylist(accessToken: accessToken, playlist: playlist) { (videos, error) in
    
            
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
                        
                        
                        
                        if self.someEntityExists(id: id!, context: context) == false {
                            
                            let video = Video(context: context)
                            video.title = title
                            video.thumbnailURL = url
                            video.videoID = videoID
                            video.playlistItemID = id
                            video.playlist = playlist
                            
                            self.saveContext(context: context)
                        }
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    func saveContext (context: NSManagedObjectContext){
        do {
            try context.save()
            print("Context was saved")
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    func someEntityExists(id: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "playlistItemID = %@", id)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try! context.count(for: fetchRequest)
        }
        return entitiesCount > 0
    }
    
    
}




