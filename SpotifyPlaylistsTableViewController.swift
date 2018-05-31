//
//  SpotifyPlaylistsTableViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/25/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit


class SpotifyPlaylistsTableViewController: UITableViewController {
    
    var spotifyPlaylistStore = SpotifyPlaylist.sharedInstance()
    var spotifyAccessToken: String!
    var playlistID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.spotifyPlaylistStore.playlists.removeAll()
        SpotifyClient.sharedInstance().fetchPlaylists(accessToken: spotifyAccessToken) { (playlists, error) in
            
            if error == nil {
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
                
            } else {
                print(error)
            }
        }
        
    }
  
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return spotifyPlaylistStore.playlists.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! CustomTableViewCell
        let playlist = spotifyPlaylistStore.playlists[indexPath.row]
        
        
        
        SpotifyClient.sharedInstance().downloadimageData(photoURL: URL(string: playlist.thumbnailURLString)! ) { (imageData, error) in
            if error == nil {
                DispatchQueue.main.async() {
                    
                    cell.update(with: UIImage(data: imageData!) , title: playlist.name)
                    
                }
            }
        }
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = spotifyPlaylistStore.playlists[indexPath.row]
        self.playlistID = playlist.id
        
        performSegue(withIdentifier: "getSpotifyPlaylistTracks", sender: self)
        
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SpotifyPlaylistView {
            destination.spotifyAccessToken = self.spotifyAccessToken
            destination.playlistID = self.playlistID
        }
    }
}

