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
    

    @IBOutlet weak var spotifyLoginButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        spotifyLoginButton = SpotifyLoginButton(viewController: self, scopes: [.streaming, .userLibraryRead])
       
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error != nil {
                // User is not logged in, show log in flow.
                print(accessToken!)
                
            }
        }
    }
    
    @IBAction func spotifyLoginButtonPressed(_ sender: UIButton) {
        
        SpotifyLoginPresenter.login(from: self, scopes: [.streaming, .userLibraryRead])
    }
    
    
}
