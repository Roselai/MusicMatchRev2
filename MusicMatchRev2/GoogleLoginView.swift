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
            let accessToken = signIn.currentUser.authentication.accessToken
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: Constants.UserDefaultKeys.YouTubeAccessToken)
            
           goBackToOneButtonTapped(self)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "GoBackToSearchResult", sender: self)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
