//
//  SignInViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/10/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import UIKit
import GoogleSignIn


class SignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    var accessToken: String!
   
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().clientID = "335355113348-3tku90o1ltp2hhvlhf0eehin6kpinb28.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.Youtube)
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.YouTubeForceSSL)
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.YouTubeReadOnly)
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.YouTubeUpload)
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.YouTubePartner)
        GIDSignIn.sharedInstance().scopes.append(Constants.YouTubeAuthScopes.YouTubePartnerChannelAudit)
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().signInSilently()
        
        
        // TODO(developer) Configure the sign-in button look/feel
        
        signInButton.style = .wide
        signInButton.colorScheme = .dark
        
  
    }
    
   
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            print(err)
            
        }
        else {
            
            accessToken = user.authentication.accessToken
            //performSegue(withIdentifier: "showPlaylists", sender: self)
            
        }
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}





