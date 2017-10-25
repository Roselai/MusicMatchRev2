//
//  YouTubeConvenience.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/19/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation

extension YoutubeAPI {
    
    struct RequestBody: Codable {
        let snippet: Snippet
    }
    
    struct Snippet: Codable {
        let playlistId: String
        let resourceId: ResourceId
    }
    
    struct ResourceId: Codable {
        let kind: String
        let videoId: String
    }
    
    
    func addVideoToPlaylist(accessToken: String!, playlistID: String!, videoID: String!) {
    
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        

        
        let resourceId = ResourceId(kind: "youtube#video", videoId: videoID)
        let snippet = Snippet(playlistId: playlistID, resourceId: resourceId)
       let jsonBody = RequestBody(snippet: snippet)
        
        
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
             let jsonData = try? jsonEncoder.encode(jsonBody)
        


        
        _ = YoutubeAPI.sharedInstance().taskForPOSTMethod(method: method, bodyParameters: parameters as [String : AnyObject], jsonBody: jsonData, completionHandlerForPOST: { (result, error) in
            
            if error == nil {
                print("video posted")
            } else {
                print(error?.localizedDescription)
                
            }
        })
        
        
        }
    
    func fetchUserPlaylists (accessToken: String!, completion: @escaping (_ result: Array<Any>?, _ error: Error?) -> Void) {
        
        
        let method = Constants.YouTubeMethod.PlaylistMethod
        
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.Mine : Constants.YoutubeParameterValues.MineValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (result, error) in
            if error == nil {
                
                if let result = result {
                    let playlistsArray = result["items"] as! [[String:Any]]
                    var playlists : [[String:String]] = []
                    
                    for index in 0 ... playlistsArray.count-1 {
                        
                        let playlistDict = playlistsArray[index] as [String: Any]
                        
                        var playlistDetailsDict : [String: String] = [:]
                        
                        playlistDetailsDict["id"] = playlistDict["id"] as? String
                        
                        if let playlistSnippetDict = playlistDict["snippet"] as? [String:Any] {
                            
                            playlistDetailsDict["title"] = playlistSnippetDict["title"] as? String
                            playlistDetailsDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! [String: Any])["default"] as! [String: Any])["url"] as? String
                            
                        }
                        
                        playlists.append(playlistDetailsDict)
                        
                    }
                    OperationQueue.main.addOperation {
                        
                    completion(playlists, nil)
                    }
                }
                
            } else {
                OperationQueue.main.addOperation {
                completion(nil, error)
                }
                
            }
        })
        
    }

    
    /*
    func getVideosFromPlaylist(accessToken: String?, playlistID: String?, completionHandler: @escaping (_ result: Array<Any>?, _ error: NSError?) -> Void) {
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken!,
                          Constants.YouTubeParameterKeys.PlaylistID: playlistID ]
            
       _ = taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (result, error) in
            
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
 */
    
    func searchForVideo(searchQuery: String, completion: @escaping (_ result: Array<Any>?, _ error: Error?) -> Void ) {
        
        let method = Constants.YouTubeMethod.SearchMethod
        
        let parameters = [Constants.YouTubeParameterKeys.type : Constants.YoutubeParameterValues.typeValue,
                          Constants.YouTubeParameterKeys.Order : Constants.YoutubeParameterValues.orderValue,
                          Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.MaxResults : "\(Constants.YoutubeParameterValues.ResultLimit)",
            Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
            "q": "\(searchQuery)"]
        
        
        
        _ =  YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (result, error) in
            
            
            if error == nil {
                if let result = result {
                    
                    var videosArray = result["items"] as! [[String:Any]]
                    var videos : [[String:String]] = []
            
                
                for index in 0 ... videosArray.count-1 {
                    let videoDict = videosArray[index] as [String: Any]
                    var videoDetailsDict : [String: String] = [:]
                
                    videoDetailsDict["id"] = (videoDict["id"] as! [String: Any])["videoId"] as! String?
                    
                    if let snippetDict = videoDict["snippet"] as? [String: Any] {
                    
                        videoDetailsDict["title"] = snippetDict["title"] as? String
                        videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! [String: Any])["default"] as! [String: Any])["url"] as! String?
                        
                    }
                    videos.append(videoDetailsDict)
                    }
                    
                    OperationQueue.main.addOperation {
                        
                        completion(videos, nil)
                    }
                }
            }
            else {
                OperationQueue.main.addOperation {
                    completion(nil, error)
                }
            }
            
        
        })
    }
            
    
}
    

