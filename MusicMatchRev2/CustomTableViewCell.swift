//
//  PlaylistCell.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/17/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    
    func update(with image: UIImage?, title: String?) {
        
        if let imageToDisplay = image {
            
            
            self.imageView?.image = imageToDisplay
            self.textLabel?.text = title
            
        } else {
            
            self.imageView?.image = nil
           self.textLabel?.text = ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.numberOfLines = 3
        self.textLabel?.lineBreakMode = .byWordWrapping
        update(with: nil, title: nil)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel?.numberOfLines = 3
        self.textLabel?.lineBreakMode = .byWordWrapping
        update(with: nil, title: nil)
        
    }
    
}

