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
import GoogleCast

class SearchResultViewController: UITableViewController, CreatePlaylistViewDelegate {
  
    var videoID: String!
    var accessToken: String!
    let searchDataSource = YTTableViewDataSource()
 
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext: NSManagedObjectContext!
    
    private var castButton: GCKUICastButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accessToken = appDelegate.accessToken
   
        tableView.dataSource = searchDataSource
        managedContext = persistentContainer.viewContext
        

        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configure(cell, for: indexPath)
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        videoID =  (searchDataSource.items[indexPath.row])[Constants.YouTubeResponseKeys.VideoID]
        
        NotificationCenter.default.post(name: NSNotification.Name("Cell Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : videoID])
        
    }
    
    
    func performSearch(searchQueryString: String) {
        YoutubeAPI.sharedInstance().searchForVideo(searchQuery: searchQueryString) { (videos, error) in
            guard error == nil else {
                print("Error fetching videos")
                self.searchDataSource.items.removeAll()
                return
            }
            if videos != nil {
                print("Successfully retrieved \(String(describing: videos?.count)) videos")
                self.searchDataSource.items = videos!
                
                self.videoID = (videos![0])[Constants.YouTubeResponseKeys.VideoID]
                //send first result videoID to player for load
                NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : self.videoID])
                
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        let video = searchDataSource.items[indexPath.row]
        
        let imageURL = URL(string: video[Constants.YouTubeResponseKeys.ThumbnailURL]!)
        
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            
            
            
            if let error = error {
                print("Error downloading picture: \(error)")
            } else {
                // No errors found.
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let title = video[Constants.YouTubeResponseKeys.Title]
                        
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
    


    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let segueAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [segueAction])
        return swipeConfig
        
    }
    
    func contextualSegueAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let video = searchDataSource.items[indexPath.row]
        videoID = video[Constants.YouTubeResponseKeys.VideoID]
        
        let action = UIContextualAction(style: .normal, title: "Add") { (contextAction, sourceView, completionHandler) in
            
            
            let title = "Add Video"
            let message = "Select a playlist to add the video to"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let createPlaylistAction = UIAlertAction(title: "Create new playlist", style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "createAPlaylist", sender: self)
            })
            ac.addAction(createPlaylistAction)
            
            
            self.fetchUserPlaylists(completion: { (playlistsArray) in
                
                    if let playlists = playlistsArray {
                        
                        for playlist in playlists {
                            
                            let addAction = self.alertAddAction(playlist: playlist)
                            ac.addAction(addAction)
                        }
                        
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ,
                                             handler: nil)
            ac.addAction(cancelAction)
            self.present(ac, animated: true, completion: nil)
            
            completionHandler(true)
            
        }
        
        action.image = UIImage(named: "addIcon")
        action.backgroundColor = UIColor.black
        return action
        
    }
    
    func fetchUserPlaylists(completion: @escaping ([Playlist]?) -> Void) {
        
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        let sortByTitle = NSSortDescriptor(key: #keyPath(Playlist.title),
                                               ascending: true)
        fetchRequest.sortDescriptors = [sortByTitle]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPlaylists = try viewContext.fetch(fetchRequest)
                completion(allPlaylists)
            } catch {
                completion(nil)
                print("Could not retreive Playlists")
            }
        }
        
    }
    
    func alertAddAction (playlist: Playlist) -> UIAlertAction {
        let addAction = UIAlertAction(title: playlist.title, style: .default ,
                                      handler: { (action) -> Void in
                                   
                                        let accessToken = self.appDelegate.accessToken
                                       
                                        
                                        if self.someEntityExists(id: self.videoID, playlist: playlist) == false {
                                        
                                    
                                            self.addVideo(accessToken: accessToken!, playlist: playlist, videoID: self.videoID)
                                        }
                                        
                                        
                                        else {
                                            
                                            let duplicateAlert = UIAlertController(title: "Video Is Already In Playlist",
                                                                       message: "Add again?",
                                                                       preferredStyle: .alert)
                                            
                                            
                                            let addVideoAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                                
                                               self.addVideo(accessToken: self.accessToken, playlist: playlist, videoID: self.videoID)
                                                
                                            })
                                            let cancelAddVideoAction = UIAlertAction(title: "No", style: .cancel ,
                                                                             handler: nil)
                                            
                                            
                                            duplicateAlert.addAction(cancelAddVideoAction)
                                            duplicateAlert.addAction(addVideoAction)
                                            self.present(duplicateAlert, animated: true, completion: nil)
                                            print("this video already exists in playlist")
                                            
                                        }
                                        
        })
        
        return addAction
    }
    
    func saveContext (context: NSManagedObjectContext){
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    func someEntityExists(id: String, playlist: Playlist) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let videoIdPredicate = NSPredicate(format: "videoID = %@", id)
        let playlistPredicate = NSPredicate(format: "playlist = %@", playlist)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [videoIdPredicate, playlistPredicate])
        fetchRequest.predicate = andPredicate
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreatePlaylistView {
            destination.videoID = self.videoID
            destination.persistentContainer = self.persistentContainer
            destination.managedContext = self.managedContext
        destination.delegate = self
        }
    }
    
    func finishPassing(playlist: Playlist, videoID: String) {
        self.addVideo(accessToken: self.accessToken, playlist: playlist, videoID: videoID)

        
        self.saveContext(context: self.managedContext)
        
        print("Playlist Object Received")
       // print(playlist.title!, videoID)
    }
    
    func addVideo(accessToken: String, playlist: Playlist, videoID: String){
        YoutubeAPI.sharedInstance().addVideoToPlaylist(accessToken: accessToken, playlistID: playlist.id, videoID: videoID, completion: { (videoDetails, error) in
            
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            guard videoDetails != nil else {
                print("Could not retreive any video details.")
                return
            }
            //Save the context
            
            let video = Video(context: self.managedContext)
            video.title = videoDetails?[Constants.YouTubeResponseKeys.Title]
            video.videoID = videoDetails?[Constants.YouTubeResponseKeys.VideoID]
            video.playlistItemID = videoDetails?[Constants.YouTubeResponseKeys.PlaylistItemID]
            video.thumbnailURL = videoDetails?[Constants.YouTubeResponseKeys.ThumbnailURL]
            video.playlist = playlist
            
            self.saveContext(context: self.managedContext)
            
            
            NotificationCenter.default.post(name: NSNotification.Name("Video Added"), object: nil, userInfo: ["message": "Video added to \(playlist.title!) playlist"])
            
            
        })
    }
    
}
