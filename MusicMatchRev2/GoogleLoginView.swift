//
//  GoogleLoginView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/30/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST



class GoogleLoginView: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    private let scopes = [kGTLRAuthScopeYouTubeReadonly, kGTLRAuthScopeYouTube, kGTLRAuthScopeYouTubeForceSsl, kGTLRAuthScopeYouTubeYoutubepartner, kGTLRAuthScopeYouTubeUpload, kGTLRAuthScopeYouTubeYoutubepartnerChannelAudit]
    
    var accessToken: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().clientID = "335355113348-3tku90o1ltp2hhvlhf0eehin6kpinb28.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().scopes = scopes
        
    
        GIDSignIn.sharedInstance().signInSilently()
            
        
        
        signInButton.colorScheme = .dark
        signInButton.style = .wide
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
            signInButton.isEnabled = false
            
            accessToken = signIn.currentUser.authentication.accessToken
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
            
            performSegue(withIdentifier: "LoggedInToGoogle", sender: self)
            
        } else {
            signInButton.isEnabled = true
            
            print("\(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoggedInToGoogle" {
            let destinationViewController = segue.destination as! PlaylistsViewController
            destinationViewController.accessToken = self.accessToken
            
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
