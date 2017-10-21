//
//  YouTubeConvenience.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/19/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation

extension YoutubeAPI {
    
    func addVideoToPlaylist(accessToken: String!, playlistID: String!, videoID: String!) {
    
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        

        
        var jsonBody = ""
        
        YoutubeAPI.sharedInstance().taskForPOSTMethod(method: method, bodyParameters: parameters as [String : AnyObject], jsonBody: jsonBody, completionHandlerForPOST: { (result, error) in
            
            if error == nil {
                print("video posted")
            } else {
                print(error?.localizedDescription)
            }
        })
        
        
        }
    
    
    func getVideosFromPlaylist(accessToken: String?, playlistID: String?, completionHandler: @escaping (_ result: Array<Any>?, _ error: NSError?) -> Void) {
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken!,
                          Constants.YouTubeParameterKeys.PlaylistID: playlistID ]
            
        taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (result, error) in
            
            if error == nil {
                if let result = result {
                    let videosArray = result["items"] as! [[String:Any]]
                    
                    for index in 0 ... videosArray.count-1 {
                        
                        let videoDict = videosArray[index] as [String: Any]
                        var videoDetailsDict : [String: Any] = [:]
                        
                        videoDetailsDict["id"] = videoDict["id"] as! String
                        
                        if let videoSnippetDict = videoDict["snippet"] as? [String:Any] {
                            
                            videoDetailsDict["title"] = videoSnippetDict["title"] as! String
                            videoDetailsDict["thumbnail"] = ((videoSnippetDict["thumbnails"] as! [String: Any])["high"] as! [String: Any])["url"] as! String
                        }
                        
                        var newVideosArray = [[String:Any]]()
                        newVideosArray.append(videoDetailsDict)
                        completionHandler(newVideosArray, nil)
                        
                    }
                }
            } else {
                    completionHandler(nil, error)
                print(error?.localizedDescription)
            }
            
        }
    }
}
    

