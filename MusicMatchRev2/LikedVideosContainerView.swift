//
//  LikedVideosContainerView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 6/1/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LikedVideosContainerView: UIViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
  

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
   
    
    fileprivate var LikedVideos: LikedVideosView!
    fileprivate var YTPlayerViewController: YouTubePlayerViewController!
    var videoID: String!
    var queryString: String!
    var managedContext: NSManagedObjectContext!
   
    
    @IBOutlet weak var statusLabel: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
 
       managedContext = persistentContainer.viewContext
        
        logoImageView.layer.cornerRadius = 8.0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusLabel.text = ""
        statusLabel.isHidden = true
        logoImageView.isHidden = true
        
        
        
        if likedVideosExist()
        {
            topContainerView.isHidden = false
            bottomContainerView.isHidden = false
            
            guard let likedVideos = childViewControllers.first as? LikedVideosView  else  {
                fatalError("Check storyboard for missing LikedVideosView")
                
            }
            
            guard let playerController = childViewControllers.last as? YouTubePlayerViewController else  {
                fatalError("Check storyboard for missing YouTubePlayerViewController")
                
            }
            YTPlayerViewController = playerController
            LikedVideos = likedVideos
            
            
        } else {
            topContainerView.isHidden = true
            bottomContainerView.isHidden = true
            statusLabel.isHidden = false
            logoImageView.isHidden = false
            statusLabel.text = "You don't have any liked videos"
        
        }
    }
    
    
    func likedVideosExist() -> Bool{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "liked = YES")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedVideos = try managedContext.fetch(fetchRequest)
            if (fetchedVideos.count > 0){
                return (true)
            } else {
            return (false)
            }
        } catch {
            debugPrint("Failed")
            return(false)
            
        }
    }
    
    

    
}



