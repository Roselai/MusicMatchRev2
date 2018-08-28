//
//  TabBarController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 8/24/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    @IBAction func sideMenuButtonTapped(_ sender: UIBarButtonItem) {
        
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSettings),
                                               name: NSNotification.Name(rawValue: "ShowSettings"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showHelp),
                                               name: NSNotification.Name(rawValue: "ShowHelp"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSignIn),
                                               name: NSNotification.Name(rawValue: "ShowSignIn"),
                                               object: nil)
    }
  
    @objc func showSettings() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
        
    }
    @objc func showHelp() {
        performSegue(withIdentifier: "ShowHelp", sender: nil)
    }
    @objc func showSignIn() {
        performSegue(withIdentifier: "ShowSignIn", sender: nil)
    }
    
}
