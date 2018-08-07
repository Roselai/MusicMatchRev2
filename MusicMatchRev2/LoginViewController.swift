//
//  LoginViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 1/9/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//


import UIKit
import SpotifyLogin


class LoginViewController: UIViewController {
    
    var accessToken: String! = nil
    
    
    @IBOutlet weak var button: SpotifyLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if user is Logged Into Spotify
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("LoggedIntoSpotify"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loggedInSetup()
    }
    
    
    
    @objc func userLoggedIn(notification: NSNotification) {
       loggedInSetup()
    }
    
    func loggedInSetup(){
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error == nil {
                //If user is logged in go to spotify Playlists View
                self.button.isEnabled = false
                self.accessToken = accessToken
                self.performSegue(withIdentifier: "showSpotifyPlaylists", sender: self)
            } else {
                self.button.isEnabled = true
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpotifyPlaylists" {
            let destinationViewController = segue.destination as? SpotifyPlaylistsTableViewController
            destinationViewController?.spotifyAccessToken = self.accessToken
            
        }
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: SpotifyLoginButton) {
        self.dismiss(animated: true, completion: nil)
        SpotifyLoginPresenter.login(from: self, scopes: [.streaming, .userLibraryRead, .playlistReadPrivate])
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
