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
    /*
    func searchForVideo(searchQuery: String, completionHandlerForSearchForVideo: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let parameters = [Constants.YouTubeParameterKeys.type : Constants.YoutubeParameterValues.typeValue,
                          Constants.YouTubeParameterKeys.Order : Constants.YoutubeParameterValues.orderValue,
                          Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.MaxResults : "\(Constants.YoutubeParameterValues.ResultLimit)",
            Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
            "q": "\(searchQuery)"]
        
        let method = Constants.YouTubeMethod.SearchMethod
        
        
        _ =  YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (data, error) in
            
            if error == nil {
                
                let jsonDecoder = JSONDecoder()
                if let jsonData = data {
                    do {
                let searchListResponse = try? jsonDecoder.decode(SearchListResponse.self, from: jsonData)
                dump(searchListResponse)
                        completionHandlerForSearchForVideo(result as AnyObject, nil)
                    }
                
                // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                
                /*let items = result?["items"] as! [[String:AnyObject]]
                
                for index in 0 ... items.count-1 {
                    
                    let item = items[index]
                    let snippetDict = item["snippet"] as! [String: AnyObject]
                    
                    var videoDetailsDict : [String: String] = [:]
                    
                    if snippetDict["title"]?.range(of: self.searchQueryString ) != nil {
                        
                        videoDetailsDict["title"] = snippetDict["title"] as? String
                        videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! [String: AnyObject])["high"] as! [String: AnyObject])["url"] as! String?
                        videoDetailsDict["videoID"] = (item["id"] as! [String: AnyObject])["videoId"] as! String?
                        
                        
                    }*/
                    //self.videosArray.append(videoDetailsDict)
                    
                
            else {
                completionHandlerForSearchForVideo(nil, error)
            }
        })
        }
            
    */
}
    

