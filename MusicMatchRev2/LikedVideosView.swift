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
    var accessToken: String! = nil
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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        let defaults = UserDefaults.standard
        self.accessToken = defaults.string(forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accessToken != nil {
            
            managedContext = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "liked = YES")
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedVideos = fetchedResultsController?.fetchedObjects as! [Video]
            
            let initialVideo = fetchedVideos[0]
            let initialVideoID = initialVideo.videoID
            //send first result videoID to player for load
            NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : initialVideoID!])
            
        }
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
   
    
    
    
    
    
    
    func saveContext (context: NSManagedObjectContext){
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

