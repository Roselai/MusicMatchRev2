//
//  ContainerViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 8/24/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var sideMenuOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name(rawValue: "ToggleSideMenu"),
                                               object: nil)
    }

    @objc func toggleSideMenu() {
        
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuConstraint.constant = -240
        } else {
            sideMenuOpen = true
            sideMenuConstraint.constant = 0
        }
    }

}
