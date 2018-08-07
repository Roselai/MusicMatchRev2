//
//  PlaylistsTableDataSource.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/24/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit

class YTTableViewDataSource: NSObject, UITableViewDataSource {
    
    var items: [[String:String]] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "UITableViewCell"
        let cell = tableView .dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CustomTableViewCell
        return cell
        
    }
    
}
