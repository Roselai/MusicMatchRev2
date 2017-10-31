//
//  PlaylistsEditorViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/24/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit


class PlaylistsEditorViewController: UIViewController, UITableViewDelegate{
    
    
    @IBOutlet var tableView: UITableView!
    var playlistID: String!
    var videoID: String!
    var accessToken: String!
    let playlistsDataSource = YTTableViewDataSource()
    
    var insertedCache: [IndexPath]!
    var deletedCache: [IndexPath]!
    var updatedCache: [IndexPath]!
    var selectedCache = [IndexPath]()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = playlistsDataSource
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        accessToken = appDelegate.accessToken
        
        
        YoutubeAPI.sharedInstance().fetchUserPlaylists(accessToken: accessToken!) { (playlists, error) in
            guard error == nil else {
                print("Error fetching playlists")
                self.playlistsDataSource.items.removeAll()
                return
            }
            if playlists != nil {
                print("Successfully retrieved \(String(describing: playlists?.count)) playlists")
                self.playlistsDataSource.items = playlists!
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        }

        
    }
    
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let playlist = playlistsDataSource.items[indexPath.row]
        
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

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        playlistID = (playlistsDataSource.items[indexPath.row])["id"]
        YoutubeAPI.sharedInstance().addVideoToPlaylist(accessToken: self.accessToken, playlistID: self.playlistID, videoID: self.videoID!)
    
    }
    
    
    
    @IBAction func createANewPlaylist(_ sender: UIBarButtonItem) {
        
        /*
        let controller = UIAlertController(title: "" , message: "Would you like to create a new playlist?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Yes", style: .default , handler: { (action) in
           
            
           
        }))
        present(controller, animated: true, completion: nil)
 */
        
        let title = "testing"
        YoutubeAPI.sharedInstance().createPlaylist(accessToken: accessToken, title: title)
        tableView.reloadData()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        

    }
    
    
}
