//
//  SpotifyConvenience.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 4/27/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

extension SpotifyClient {
    
    
    //MARK: Get a list of the playlists owned or followed by the current Spotify user.
    
    func fetchPlaylists(accessToken: String, completionHandlerForFetchPlaylists: @escaping (_ result: [SpotifyPlaylistInformation]?, _ error: NSError?) -> Void) {
        SpotifyClient.sharedInstance().taskForGETMethod(method: Constants.SpotifyMethod.PlaylistMethod, parameters: nil, accessToken: accessToken, completionHandlerForGET: { (result, error) in
            if error == nil {
                
                guard
                    let jsonDictionary = result as? [AnyHashable:Any],
                    let playlistsArray = jsonDictionary["items"] as? [[String:AnyObject]] else {
                        return
                }
                
                
               //DispatchQueue.main.async() {
                    let playlists = SpotifyPlaylist.sharedInstance().playlistFromResults(results: playlistsArray)
                    completionHandlerForFetchPlaylists(playlists, nil)
                    
                    
                    //self.tableView.reloadData()
                //}
            }
            else {
                completionHandlerForFetchPlaylists(nil, error)
            }
            
            
        })    }
    
    //MARK: Get current user’s username
    
    func getCurrentUserID(accessToken: String, completionHandlerForGetCurrentUserID: @escaping (_ currentUserID: String?, _ error: NSError?) -> Void) {
        SpotifyClient.sharedInstance().taskForGETMethod(method: Constants.SpotifyMethod.CurrentUserProfileMethod, parameters: nil, accessToken: accessToken, completionHandlerForGET: { (result, error) in
            if error == nil {
                
                
                guard
                    let jsonDictionary = result as? [AnyHashable:Any]
                    else {
                        return
                }
                let userID = jsonDictionary["id"] as? String
                completionHandlerForGetCurrentUserID(userID!, nil)
                
            }
            else {
                completionHandlerForGetCurrentUserID(nil, error)
            }
            
            
        })    }
    
    
    //MARK: Get full details of the tracks of a playlist owned by a Spotify user.
    
    func getPlaylistTracks(accessToken: String, userID: String, playlistID:String, completionHandlerForGetPlaylistTracks: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
            let pathParameters = [Constants.SpotifyParameterKeys.PlayListID : playlistID,
                              Constants.SpotifyParameterKeys.UserID: userID]
        
        //Substitute the userID and PlaylistID into method to create a new method String
        var method = Constants.SpotifyMethod.PlaylistItemsMethod
        for (key,value) in pathParameters {
        
        let newMethod = subtituteKeyInMethod(method: method, key: key, value: value)
            method = newMethod!
        }
        
        //Use the new method String to retreive playlist tracks
            SpotifyClient.sharedInstance().taskForGETMethod(method: method, parameters: nil, accessToken: accessToken, completionHandlerForGET: { (result, error) in
                if error == nil {
                    
                    //Parse the JSON result into tracks
                    guard
                        let jsonDictionary = result as? [AnyHashable:Any],
                        let tracksArray = jsonDictionary["items"] as? [[String:AnyObject]]
                    else {
                            return
                    }
                    
                    //let tracks = SpotifyTrack.sharedInstance().trackFromResults(results: tracksArray)
                    
                    completionHandlerForGetPlaylistTracks(tracksArray as AnyObject, nil)
                } else {
                    completionHandlerForGetPlaylistTracks(nil, error)
                }
            })
        }
        
    
    
}
