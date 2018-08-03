//
//  ViewController.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/9/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//


import UIKit
import MediaPlayer




class MediaPickerViewController: UIViewController, MPMediaPickerControllerDelegate {
    
   // private var mediapicker1: MPMediaPickerController!
    
    
    var songTitle: String?
    var songArtist: String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            checkMediaAuthorization()
            
        
    }
    
    
    
    
    
    func checkMediaAuthorization() {
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.presentMediaPickerController()
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    

    
    func presentMediaPickerController() {
        let mediaPicker: MPMediaPickerController = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.delegate = self
        mediaPicker.prompt = "Please Pick a Song"
        mediaPicker.showsCloudItems = true
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    
    
    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        present(controller, animated: true, completion: nil)
    }
    
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        songTitle = (mediaItemCollection.items.first?.title)!
        songArtist = (mediaItemCollection.items.first?.artist)!
        
        performSegue(withIdentifier: "searchYouTube", sender: self)
        mediaPicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchYouTube" {
            let destinationViewController = segue.destination as! YouTubeSearchController
            destinationViewController.queryString = "\(songTitle!) \(songArtist!)"
            
        }
    }
    
    
    
    
}








