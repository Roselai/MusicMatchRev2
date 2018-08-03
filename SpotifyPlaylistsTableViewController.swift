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
    var alertMessage: String!
    var alertTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.spotifyPlaylistStore.playlists.removeAll()
        
        
        APIClient.sharedInstance().fetchPlaylists(accessToken: spotifyAccessToken) { (playlists, error) in
            
            if error == nil {
                
                if (playlists?.count)! > 0  {
                    DispatchQueue.main.async() {
                        self.tableView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async() {
                    self.alertTitle = "Oops!"
                    self.alertMessage = "You don't have any playlists"
                    self.errorAlert(title: self.alertTitle, message: self.alertMessage)
                    }
                }
                
                
            } else {
                DispatchQueue.main.async() {
                    
                self.alertTitle = "Could not retreive playlists from Spotify"
                self.alertMessage = "\(String(describing: error!.localizedDescription))"
                self.errorAlert(title: self.alertTitle, message: self.alertMessage)
                }
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
        
        
        
        _ = APIClient.sharedInstance().downloadimageData(photoURL: URL(string: playlist.thumbnailURLString)! ) { (imageData, error) in
            if error == nil {
                
                if imageData != nil {
                    
                    DispatchQueue.main.async() {
                        
                        cell.update(with: UIImage(data: imageData!) , title: playlist.name)
                        
                    }
                } else {
                    DispatchQueue.main.async() {
                        self.alertTitle = "Oops!"
                    self.alertMessage = "There is a problem getting image information."
                    self.errorAlert(title: self.alertTitle, message: self.alertMessage)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                self.alertTitle = "Could not download image."
                    self.alertMessage = "\(String(describing: error!.localizedDescription))"
                    self.errorAlert(title: self.alertTitle, message: self.alertMessage)
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
    
    func errorAlert (title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

