//
//  PlaylistViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/10/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PlaylistsViewController: CoreDataTableViewController {
    

    //var playlistID: String!
    var videoID: String!
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
    var playlist: Playlist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
let appDelegate = UIApplication.shared.delegate as! AppDelegate
        accessToken = appDelegate.accessToken
        
        
        managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchPlaylists()
      
    }


    //MARK: TableView DataSource Methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! CustomTableViewCell
        
        configure(cell, for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.playlist = (fetchedResultsController?.fetchedObjects![indexPath.row]) as! Playlist
        performSegue(withIdentifier: "showPlaylistForID", sender: self)
    }
    
    func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? CustomTableViewCell else { return }
        
        let playlist = fetchedResultsController!.object(at: indexPath) as! Playlist
        
        //TODO: Change placeHolder Image
        var image = #imageLiteral(resourceName: "addIcon")
        var title: String!
        
        if playlist.thumbnail != nil, playlist.title != nil {
            
            image = UIImage(data: playlist.thumbnail! as Data)!
            title = playlist.title
            
        } else {
            
            if let imagePath = playlist.thumbnailURL {
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
                        playlist.thumbnail = imageData as NSData?
                        self.saveContext(context: context)
                    }
                    
                    
                    DispatchQueue.main.async {
                        if playlist.thumbnail != nil{
                            image = UIImage(data: playlist.thumbnail! as Data)!
                            let title = playlist.title
                            cell.update(with: image, title: title)
                        }
                        
                    }
                })
            }
        }
        
        
        cell.update(with: image, title: title)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaylistForID" {
            
            let destinationViewController = segue.destination as! PlaylistContainerView
            
            guard playlist != nil else {return}
            
            //destinationViewController.playlistID = self.playlistID
            destinationViewController.accessToken = self.accessToken
            destinationViewController.playlist = self.playlist
 
        }
    }
    
    

    func fetchPlaylists() {
 
    
        YoutubeAPI.sharedInstance().fetchUserPlaylists(accessToken: self.accessToken) { (playlists, error) in
            guard error == nil else {
                print("Error fetching playlists")
                return
            }
            if playlists != nil {
                print("Successfully retrieved \(String(describing: playlists?.count)) playlists")
            }
            //self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            
            DispatchQueue.main.async {
                
                if let playlistsArray = playlists {
                    
                    for playlistDictionary in playlistsArray {
                        
                        let title = playlistDictionary[Constants.YouTubeResponseKeys.Title]
                        let id = playlistDictionary[Constants.YouTubeResponseKeys.PlaylistID]
                        let url = playlistDictionary[Constants.YouTubeResponseKeys.ThumbnailURL]
                        
                        
                        if self.someEntityExists(id: id!) == false {
                            
                            let playlist = Playlist(context: self.managedContext)
                            playlist.title = title
                            playlist.thumbnailURL = url
                            playlist.id = id
                            
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try! managedContext.count(for: fetchRequest)
        }
        /*catch {
            print("error executing fetch request: \(error)")
        }*/
        
        return entitiesCount > 0
    }
    
   
    
    
    
}
