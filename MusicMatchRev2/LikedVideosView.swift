//
//  LikedVideosView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 5/31/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class LikedVideosView : CoreDataTableViewController {
    
    
    
    var videoID: String!
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
    var fetchedVideos: [Video]!
    var video: Video!
    var deleteVideoIndexPath: IndexPath? = nil
    
    var likedVideosExist: Bool{
        if (fetchedVideos.count > 0){
            return (true)
        } else {
            return (false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "liked = YES")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedVideos = fetchedResultsController?.fetchedObjects as! [Video]
        
        if likedVideosExist == true {
            
            let initialVideo = fetchedVideos[0]
            let initialVideoID = initialVideo.videoID
            //send first result videoID to player for load
            NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : initialVideoID!])
        } 
        
        
    }


    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        deleteVideoIndexPath = indexPath
        guard editingStyle == .delete else { return }
        
        
            
            let alert = UIAlertController(title: "Delete Video", message: "Are you sure you want to permanently delete this video?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteVideo)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteVideo)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
            
        
        
    }
        
        func handleDeleteVideo(alertAction: UIAlertAction!) -> Void {
           
            // Fetch Video
            let video = fetchedResultsController?.object(at: deleteVideoIndexPath!)
            
            // Delete Video
            fetchedResultsController?.managedObjectContext.delete(video as! NSManagedObject)
            saveContext(context: managedContext)
        
        }
        
        func cancelDeleteVideo(alertAction: UIAlertAction!) {
            deleteVideoIndexPath = nil
        }
        
        
        
        //MARK: TableView DataSource Methods
        
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! CustomTableViewCell
            
            configure(cell, for: indexPath)
            
            return cell
        }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.video = (fetchedResultsController?.fetchedObjects![indexPath.row]) as! Video
            
            NotificationCenter.default.post(name: NSNotification.Name("Cell Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : self.video.videoID!])
        }
        
        func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
            
            guard let cell = cell as? CustomTableViewCell else { return }
            
            let video = fetchedResultsController!.object(at: indexPath) as! Video
            
            //TODO: Change placeHolder Image
            var image = #imageLiteral(resourceName: "addIcon")
            var title: String!
            title = video.title
            if video.thumbnail != nil{
                
                image = UIImage(data: video.thumbnail! as Data)!
                
                
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
    
    
        
        
        
        func saveContext (context: NSManagedObjectContext){
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save context \(error), \(error.userInfo)")
            }
        }
        
        
}

