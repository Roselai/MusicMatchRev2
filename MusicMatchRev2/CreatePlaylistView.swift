//
//  CreatePlaylistView.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/26/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol CreatePlaylistViewDelegate {
    func finishPassing(playlist: Playlist, videoID: String)
}

class CreatePlaylistView: UIViewController {
    
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var playlistPrivacyOptionTableView: UITableView!
    
    var playlistTitle: String!
    private var privacyOption: String!
    var delegate: CreatePlaylistViewDelegate?
    var videoID: String!
    let playlistPrivacyOptions = ["Public", "Unlisted", "Private"]
    var persistentContainer: NSPersistentContainer!
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    
        playlistPrivacyOptionTableView.delegate = self
        playlistPrivacyOptionTableView.dataSource = self
        
        
    }
    
    @IBAction func closeView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPlaylist(_ sender: UIBarButtonItem) {
        if playlistTitle == nil {
            let alert = UIAlertController(title: "No Playlist Name", message: "Please enter a name for the playlist", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } else {
            
            if  self.someEntityExists(title: playlistTitle) == true {
                
                
                let alert = UIAlertController(title: "A Playlist with that name already exists",
                                                       message: "Please pick another name",
                                                       preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
            
            
            //create a playlist with name
            let appdelegate =  UIApplication.shared.delegate as! AppDelegate
            let accessToken = appdelegate.accessToken!
                
            
            YoutubeAPI.sharedInstance().createPlaylist(accessToken: accessToken ,title: self.playlistTitle, privacyOption: self.privacyOption, completion: { (result, error) in
                
                guard error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                guard result != nil else {
                    print("No playlist returned")
                    return
                }
                
                if let result = result as? [String:String] {
                
                    //Save the context
                    
                    let playlist = Playlist(context: self.managedContext)
                    playlist.title = result[Constants.YouTubeResponseKeys.Title]
                    playlist.id = result[Constants.YouTubeResponseKeys.PlaylistID]
                    //playlist.thumbnailURL = result[Constants.YouTubeResponseKeys.ThumbnailURL]
                    
                    self.saveContext(context: self.managedContext)
                

               
                    self.delegate?.finishPassing(playlist: playlist, videoID: self.videoID)
                
                DispatchQueue.main.async {
                    
                self.dismiss(animated: false, completion: nil)
                    }
                }
                
            })
            }
        }
        
    }
    
    func someEntityExists(title: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try! managedContext.count(for: fetchRequest)
        }
        /*catch {
         print("error executing fetch request: \(error)")
         }*/
        
        return entitiesCount > 0
    }
    
    func saveContext (context: NSManagedObjectContext){
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    
}



extension CreatePlaylistView: UITableViewDelegate {
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistPrivacyOptions.count
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
         cell.accessoryType = .checkmark
            self.privacyOption = cell.textLabel?.text
         
         }
    }
}

extension CreatePlaylistView: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privacyCell",
                                                 for: indexPath)
        
        let text = playlistPrivacyOptions[indexPath.row]
        cell.textLabel?.text = text
         cell.textLabel?.textColor = UIColor.black
        
        if cell.textLabel?.text == "Public"  {
            
            cell.accessoryType = .checkmark
            self.privacyOption = cell.textLabel?.text
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }
}


extension CreatePlaylistView: UITextFieldDelegate {
    
    @IBAction func playlistNameTextFieldEditingChanged(_ sender: UITextField) {
        
        if let text = sender.text, !text.isEmpty {
            playlistTitle = text
        } else {
            playlistTitle = nil
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
    }
    
}




