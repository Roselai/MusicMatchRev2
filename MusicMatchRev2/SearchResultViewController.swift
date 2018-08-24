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
    
    var videoId: String!
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
    var alertTitle: String!
    var alertMessage: String!
    
    
    
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
        accessToken = defaults.string(forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        let cell =
            tableView.dequeueReusableCell(withIdentifier: identifier,
                                          for: indexPath) as! CustomTableViewCell
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        configure(cell, for: indexPath)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        videoId =  (searchDataSource.items[indexPath.row])[Constants.YouTubeResponseKeys.VideoID]
        
        NotificationCenter.default.post(name: NSNotification.Name("Cell Selected"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : videoId])
        
    }
    
    
    func performSearch(searchQueryString: String, completion: @escaping (_ success: Bool) -> Void){
        APIClient.sharedInstance().searchForVideo(searchQuery: searchQueryString) { (videos, error) in
            guard error == nil else {
                
                DispatchQueue.main.async {
                    self.alertTitle = "Error searching for videos"
                    self.alertMessage = "\(String(describing: error!.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                
                self.searchDataSource.items.removeAll()
                completion(false)
                return
            }
            
            guard videos != nil else {
                DispatchQueue.main.async {
                    self.alertTitle = "Oops!"
                    self.alertMessage = "No videos were returned from your search"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                completion(false)
                return
            }
            
            
            self.searchDataSource.items = videos!
            
            
            
            //send first result videoID to player for load
            self.videoId = (videos![0])[Constants.YouTubeResponseKeys.VideoID]
            NotificationCenter.default.post(name: NSNotification.Name("Initial Video ID"), object: nil, userInfo: [Constants.YouTubeResponseKeys.VideoID : self.videoId])
            
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            completion(true)
            
        }
    }
    
    
    
    
    
    func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        
        let spinner = setupSpinner()
        
        
        let video = searchDataSource.items[indexPath.row]
        let videoID = video[Constants.YouTubeResponseKeys.VideoID]
        
        if (checkIfLikedVideo(videoID: videoID!)) {
            
            cell.backgroundColor = UIColor(displayP3Red: 114/255, green: 208/255, blue: 245/255, alpha: 1.0)
            
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        
        
        let imageURL = URL(string: video[Constants.YouTubeResponseKeys.ThumbnailURL]!)
        
        _ = APIClient.sharedInstance().downloadimageData(photoURL: imageURL!) { (data, error) in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.alertTitle = "Could not download image."
                    self.alertMessage = "\(String(describing: error?.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            guard data != nil else {
                DispatchQueue.main.async {
                    self.alertTitle = "Oops!"
                    self.alertMessage = "There is a problem getting image information."
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            if let imageData = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    let title = video[Constants.YouTubeResponseKeys.Title]
                    
                    if let cell = self.tableView.cellForRow(at: indexPath)
                        as? CustomTableViewCell {
                        
                        cell.update(with: image, title: title)
                        
                        
                        
                    }
                }
            }
            DispatchQueue.main.async {
                spinner.stopAnimating()
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
        videoId = video[Constants.YouTubeResponseKeys.VideoID]
        
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
        
        managedContext.perform {
            do {
                let allPlaylists = try self.managedContext.fetch(fetchRequest)
                completion(allPlaylists)
            } catch {
                completion(nil)
                debugPrint("Could not retreive Playlists")
            }
        }
        
    }
    
    func alertAddAction (playlist: Playlist) -> UIAlertAction {
        let addAction = UIAlertAction(title: playlist.title, style: .default ,
                                      handler: { (action) -> Void in
                                        
                                        let playlistPredicate = NSPredicate(format: "playlist = %@", playlist)
                                        
                                        if self.someEntityExists(id: self.videoId, addPredicate: playlistPredicate ) == false {
                                            
                                            //setup activityindicator
                                            let spinner = self.setupSpinner()
                                            
                                            
                                            self.addVideo(accessToken: self.accessToken!, playlist: playlist, videoID: self.videoId, completion: { (video) in
                                                
                                                DispatchQueue.main.async {
                                                    spinner.stopAnimating()
                                                }
                                                
                                            })
                                        }
                                            
                                            
                                        else {
                                            
                                            let duplicateAlert = UIAlertController(title: "Video Is Already In Playlist",
                                                                                   message: "Add again?",
                                                                                   preferredStyle: .alert)
                                            
                                            
                                            let addVideoAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                                
                                                //setup activityindicator
                                                let spinner = self.setupSpinner()
                                                
                                                self.addVideo(accessToken: self.accessToken!, playlist: playlist, videoID: self.videoId, completion: { (video) in
                                                    
                                                    DispatchQueue.main.async {
                                                        spinner.stopAnimating()
                                                    }
                                                })
                                                
                                            })
                                            let cancelAddVideoAction = UIAlertAction(title: "No", style: .cancel ,
                                                                                     handler: nil)
                                            
                                            
                                            duplicateAlert.addAction(cancelAddVideoAction)
                                            duplicateAlert.addAction(addVideoAction)
                                            self.present(duplicateAlert, animated: true, completion: nil)
                                            
                                            
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
    
    
    func someEntityExists(id: String, addPredicate: NSPredicate? = nil) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let videoIdPredicate = NSPredicate(format: "videoID = %@", id)
        if addPredicate != nil {
            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [videoIdPredicate, addPredicate!])
            fetchRequest.predicate = andPredicate
            
        } else {
            fetchRequest.predicate = videoIdPredicate
        }
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try! managedContext.count(for: fetchRequest)
        }
        /*catch {
         print("error executing fetch request: \(error)")
         }*/
        
        return entitiesCount > 0
    }
    
    func checkIfLikedVideo (videoID: String) -> Bool {
        
        
        let likedPredicate = NSPredicate(format: "liked = YES")
        
        if (someEntityExists(id: videoID, addPredicate: likedPredicate)) {
            return true
        } else {
            return false
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreatePlaylistView {
            destination.videoID = self.videoId
            destination.persistentContainer = self.persistentContainer
            destination.managedContext = self.managedContext
            destination.delegate = self
        }
    }
    
    func finishPassing(playlist: Playlist, videoID: String) {
        
        //setup activityindicator
        let spinner = self.setupSpinner()
        
        addVideo(accessToken: accessToken, playlist: playlist, videoID: videoID) { (video) in
            
            playlist.thumbnail = video?.thumbnail
            playlist.thumbnailURL = video?.thumbnailURL
            self.saveContext(context: self.managedContext)
            
            DispatchQueue.main.async {
                spinner.stopAnimating()
            }
            
        }
    }
    
    func addVideo(accessToken: String, playlist: Playlist, videoID: String, completion: @escaping (_ video: Video?) -> Void) {
        APIClient.sharedInstance().addVideoToPlaylist(accessToken: accessToken, playlistID: playlist.id, videoID: videoID, completion: { (videoDetails, error) in
            
            guard error == nil else {
                completion(nil)
                DispatchQueue.main.async {
                    self.alertTitle = "There was a problem with your request"
                    self.alertMessage = "\(String(describing: error!.localizedDescription))"
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
                return
            }
            
            guard videoDetails != nil else {
                DispatchQueue.main.async {
                    self.alertTitle = "Oops!"
                    self.alertMessage = "There is a problem getting video information."
                    self.alertUser(title: self.alertTitle, message: self.alertMessage)
                }
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
            
            completion(video)
            
            
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
                    //print("Recognized a double tap")
                    
                    
                    let video = searchDataSource.items[tapIndexPath.row]
                    let videoID = video[Constants.YouTubeResponseKeys.VideoID]
                    
                    if (checkIfLikedVideo(videoID: videoID!) == false) {
                        
                        let saveVideo = Video(context: self.managedContext)
                        saveVideo.title = video[Constants.YouTubeResponseKeys.Title]
                        saveVideo.videoID = video[Constants.YouTubeResponseKeys.VideoID]
                        saveVideo.playlistItemID = video[Constants.YouTubeResponseKeys.PlaylistItemID]
                        saveVideo.thumbnailURL = video[Constants.YouTubeResponseKeys.ThumbnailURL]
                        saveVideo.liked = true
                        
                        self.saveContext(context: self.managedContext)
                        
                        configure(tappedCell, for: tapIndexPath)
                        
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

extension UIViewController {
    
    func alertUser (title: String, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func setupSpinner () -> UIActivityIndicatorView {
        // Create the Activity Indicator
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        
        
        activityIndicator.startAnimating()
        return activityIndicator
    }
}


