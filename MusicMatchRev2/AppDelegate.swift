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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        stack.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.saveContext()
    }
    

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    

    
    /*
    //MARK: Deprecated iOS 8.0 and older
    func application(application: UIApplication,
                     openURL url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        var _: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey.rawValue: sourceApplication as AnyObject,
                                      UIApplicationOpenURLOptionsAnnotationKey.rawValue: annotation as AnyObject]
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }*/
    
    
   
    
    

}

