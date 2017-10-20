//
//  SignInViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/19/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class SignInViewController: UIViewController {
    
    

    @IBOutlet weak var signInButton: GIDSignInButton!
    private let scopes = [kGTLRAuthScopeYouTubeReadonly, kGTLRAuthScopeYouTube]
    
    override func viewDidLoad() {
        super.viewDidLoad()

       /* GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().clientID = "335355113348-3tku90o1ltp2hhvlhf0eehin6kpinb28.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        */
    }
    
  
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
