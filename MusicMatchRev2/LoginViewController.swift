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
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("LoggedIntoSpotify"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error == nil {
                print("successfully logged in")
                self.button.isEnabled = false
                self.accessToken = accessToken
                self.performSegue(withIdentifier: "LoggedIntoSpotify", sender: self)
            } else {
                self.button.isEnabled = true
            }
        }
    }
    
    
    
    @objc func userLoggedIn(notification: NSNotification) {
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error == nil {
                print("successfully logged in")
                self.button.isEnabled = false
                self.accessToken = accessToken
                self.performSegue(withIdentifier: "LoggedIntoSpotify", sender: self)
            } else {
                self.button.isEnabled = true
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoggedIntoSpotify" {
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
