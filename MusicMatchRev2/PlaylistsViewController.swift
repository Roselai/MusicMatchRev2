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



class PlaylistsViewController: CoreDataTableViewController, UIPopoverPresentationControllerDelegate{
    
    
    //var playlistID: String!
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
    var playlist: Playlist!
    var fetchedPlaylists: [Playlist]!
    var playlistIDArray: [String] = []
    var alertTitle: String!
    var alertMessage: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        let defaults = UserDefaults.standard
        self.accessToken = defaults.string(forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
        
        if accessToken != nil {
            
            managedContext = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedPlaylists = fetchedResultsController?.fetchedObjects as! [Playlist]
            
            fetchPlaylists()
            
        }
        
        
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
        title = playlist.title
        if playlist.thumbnail != nil{
            
            image = UIImage(data: playlist.thumbnail! as Data)!
            
            
        } else {
            
            if let imagePath = playlist.thumbnailURL {
                let url = URL(string: imagePath)
                _ = APIClient.sharedInstance().downloadimageData(photoURL: url!, completionHandlerForDownloadImageData: { (imageData, error) in
                    
                    // GUARD - check for error
                    guard error == nil else {
                        DispatchQueue.main.async() {
                            self.alertTitle = "Could not download image."
                            self.alertMessage = "\(String(describing: error?.localizedDescription))"
                            self.alertUser(title: self.alertTitle, message: self.alertMessage)
                        }
                        return
                    }
                    
                    // GUARD - check for valid data
                    guard let imageData = imageData else {
                        DispatchQueue.main.async() {
                            self.alertTitle = "Oops!"
                            self.alertMessage = "There is a problem getting image information."
                            self.alertUser(title: self.alertTitle, message: self.alertMessage)
                        }
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
            
            destinationViewController.accessToken = self.accessToken
            destinationViewController.playlist = self.playlist
            destinationViewController.managedContext = self.managedContext
            
        }
    }
    
    
    
    func fetchPlaylists() {
        
        
        APIClient.sharedInstance().fetchUserPlaylists(accessToken: self.accessToken!) { (playlists, error) in
            guard error == nil else {
                DispatchQueue.main.async() {
                    self.alertTitle = "There is a problem with your request"
                    self.alertMessage = "\(String(describing: error?.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            guard (playlists?.count)! > 0 else {
                DispatchQueue.main.async() {
                    self.alertTitle = "You don't have any playlists"
                    self.alertMessage = "\(String(describing: error?.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            guard playlists != nil else {
                DispatchQueue.main.async() {
                    self.alertTitle = "There is a problem retreiving playlists"
                    self.alertMessage = "\(String(describing: error?.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            
            
           // DispatchQueue.main.async {
                
                if let playlistsArray = playlists {
                    
                    for playlistDictionary in playlistsArray {
                        
                        let title = playlistDictionary[Constants.YouTubeResponseKeys.Title]
                        let id = playlistDictionary[Constants.YouTubeResponseKeys.PlaylistID]
                        let url = playlistDictionary[Constants.YouTubeResponseKeys.ThumbnailURL]
                        
                        
                        self.playlistIDArray.append(id!)
                        
                        if self.someEntityExists(id: id!) == false {
                            
                            let playlist = Playlist(context: self.managedContext)
                            playlist.title = title
                            playlist.thumbnailURL = url
                            playlist.id = id
                            
                            self.saveContext(context: self.managedContext)
                        }
                        
                        
                    }
                    
                }
                self.deletePlaylists()
            //}
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
    
    
    func deletePlaylists() {
        for playlist in fetchedPlaylists {
            
            if playlistIDArray.contains(playlist.id!) {
                
            } else {
                
                managedContext.delete(playlist)
                saveContext(context: managedContext)
                
            }
        }
    }
    
    func alertUser (title: String, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}
