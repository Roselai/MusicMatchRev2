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



class SearchResultViewController: UITableViewController, CreatePlaylistViewDelegate, UIGestureRecognizerDelegate {
    
    var videoID: String!
    var accessToken: String! = nil
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(SearchResultViewController.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        self.tableView.addGestureRecognizer(doubleTapRecognizer)
        doubleTapRecognizer.delegate = self
        
        tableView.dataSource = searchDataSource
        managedContext = persistentContainer.viewContext
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        self.accessToken = defaults.string(forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
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
        let videoID = video[Constants.YouTubeResponseKeys.VideoID]
        
        let likedPredicate = NSPredicate(format: "liked == YES")
        
        if (someEntityExists(id: videoID!, addPredicate: likedPredicate)) == true {
            cell.textLabel?.textColor = UIColor(displayP3Red: 114/255, green: 208/255, blue: 245/255, alpha: 1.0)
        }
        
        
        
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
        
        if accessToken != nil {
            let segueAction = self.contextualSegueAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [segueAction])
            return swipeConfig
        } else {
            let loginAlert = UIAlertController(title: "Login",
                                               message: "Login to YouTube is required to add video(s) to playlist(s)",
                                               preferredStyle: .alert)
            
            let loginAction = UIAlertAction(title: "Login", style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "LogInToGoogle", sender: self)
                
            })
            let cancelAction = UIAlertAction(title: "No", style: .cancel ,
                                             handler: nil)
            
            
            loginAlert.addAction(loginAction)
            loginAlert.addAction(cancelAction)
            self.present(loginAlert, animated: true, completion: nil)
            
            
            return nil
        }
        
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
                                        
                                        let playlistPredicate = NSPredicate(format: "playlist = %@", playlist)
                                        
                                        if self.someEntityExists(id: self.videoID, addPredicate: playlistPredicate ) == false {
                                            
                                            
                                            self.addVideo(accessToken: self.accessToken!, playlist: playlist, videoID: self.videoID, completion: { (video, error) in
                                            })
                                        }
                                            
                                            
                                        else {
                                            
                                            let duplicateAlert = UIAlertController(title: "Video Is Already In Playlist",
                                                                                   message: "Add again?",
                                                                                   preferredStyle: .alert)
                                            
                                            
                                            let addVideoAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                                
                                                self.addVideo(accessToken: self.accessToken!, playlist: playlist, videoID: self.videoID, completion: { (video, error) in
                                                })
                                                
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
    
    func someEntityExists(id: String, addPredicate: NSPredicate) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let videoIdPredicate = NSPredicate(format: "videoID = %@", id)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [videoIdPredicate, addPredicate])
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
        
        addVideo(accessToken: accessToken, playlist: playlist, videoID: videoID) { (video, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            playlist.thumbnail = video?.thumbnail
            playlist.thumbnailURL = video?.thumbnailURL
            self.saveContext(context: self.managedContext)
            
            
        }
        print("Playlist Object Received")
    }
    
    func addVideo(accessToken: String, playlist: Playlist, videoID: String, completion: @escaping (_ video: Video?, _ error: Error?) -> Void) {
        YoutubeAPI.sharedInstance().addVideoToPlaylist(accessToken: accessToken, playlistID: playlist.id, videoID: videoID, completion: { (videoDetails, error) in
            
            guard error == nil else {
                print(error?.localizedDescription)
                completion(nil, error)
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
            
            completion(video, nil)
            
        })
    }
    
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    //Double Tap to like video
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = gestureRecognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? CustomTableViewCell {
                    print("Recognized a double tap")
                    
                    let video = searchDataSource.items[tapIndexPath.row]
                    let videoID = video[Constants.YouTubeResponseKeys.VideoID]
                    let likedPredicate = NSPredicate(format: "liked == YES")
                    
                    if (someEntityExists(id: videoID!, addPredicate: likedPredicate)) == false {
                        
                        let saveVideo = Video(context: self.managedContext)
                        saveVideo.title = video[Constants.YouTubeResponseKeys.Title]
                        saveVideo.videoID = video[Constants.YouTubeResponseKeys.VideoID]
                        saveVideo.playlistItemID = video[Constants.YouTubeResponseKeys.PlaylistItemID]
                        saveVideo.thumbnailURL = video[Constants.YouTubeResponseKeys.ThumbnailURL]
                        saveVideo.liked = true
                        
                        self.saveContext(context: self.managedContext)
                        
                        
                        //Video added to liked Videos notification
                        NotificationCenter.default.post(name: NSNotification.Name("Video Added"), object: nil, userInfo: ["message": "Video added to liked videos"])
                        
                    } else {
                        
                        //Show alert to user saying video has already been liked
                        let duplicateAlert = UIAlertController(title: "Liked",
                                                               message: "Video has already been liked before",
                                                               preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .cancel ,
                                                     handler: nil)
                        duplicateAlert.addAction(okAction)
                        self.present(duplicateAlert, animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    
}


