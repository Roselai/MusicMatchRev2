//
//  AppDelegate.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/9/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import UIKit
import GoogleSignIn
import SpotifyLogin




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    

    var window: UIWindow?
    let stack = CoreDataStack()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        stack.autoSave(60)
       
        window?.clipsToBounds = true
        
        SpotifyLogin.shared.configure(
            clientID: Constants.Spotify.ClientID,
            clientSecret: Constants.Spotify.ClientSecret,
            redirectURL: URL(string: Constants.Spotify.RedirectURLString)!)
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
      
        stack.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
      
        stack.saveContext()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if(url.scheme?.isEqual("musicmatchrev2"))! {
        
            
            return SpotifyLogin.shared.applicationOpenURL(url, completion: { (error) in
                
                if error == nil {
                   
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("LoggedIntoSpotify"), object: nil)

                }
                else {
                    print("could not login")
                }
            })
        
        } else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        
    }
    

}

