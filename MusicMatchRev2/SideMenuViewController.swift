//
//  MenuTableViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 8/24/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        switch indexPath.row {
        case 0: NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
        case 1: NotificationCenter.default.post(name: NSNotification.Name("ShowHelp"), object: nil)
        case 2: NotificationCenter.default.post(name: NSNotification.Name("ShowSignIn"), object: nil)
        default: break
            
        }
    }

}
