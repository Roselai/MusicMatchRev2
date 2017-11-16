//
//  YouTubeConvenience.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/19/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import CoreData

extension YoutubeAPI {
    
    func addVideoToPlaylist(accessToken: String!, playlistID: String!, videoID: String!, completion: @escaping (_ result: [String:String]?, _ error: Error?) -> Void ) {
        
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
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
        
        let resourceId = ResourceId(kind: "youtube#video", videoId: videoID)
        let snippet = Snippet(playlistId: playlistID, resourceId: resourceId)
        let jsonBody = RequestBody(snippet: snippet)
        
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData = try? jsonEncoder.encode(jsonBody)
        
        
        
        
        _ = YoutubeAPI.sharedInstance().taskForPOSTMethod(method: method, bodyParameters: parameters as [String : AnyObject], jsonBody: jsonData, completionHandlerForPOST: { (result, error) in
            
            if error == nil {
                print("video posted")
                
                if let result = result {
                    
                    

                   // var videosArray = result[Constants.YouTubeResponseKeys.Items] //as! [[String:Any]]
        
                        
                    
                        let snippetDict = result[Constants.YouTubeResponseKeys.Snippet] as? [String:Any]
                        
                        let playlistItemID = result[Constants.YouTubeResponseKeys.PlaylistItemID] as? String
                    let videoID = (snippetDict![Constants.YouTubeResponseKeys.ResourceID] as! [String:Any])[Constants.YouTubeResponseKeys.VideoID] as? String
                        let videoTitle = snippetDict![Constants.YouTubeResponseKeys.Title] as? String
                        let videoThumbnailURL = ((snippetDict![Constants.YouTubeResponseKeys.Thumbnails] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailKeys.Default] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailURL] as? String
                        
                        

                        let videoDetailsDict = [Constants.YouTubeResponseKeys.PlaylistItemID : playlistItemID,
                                                Constants.YouTubeResponseKeys.VideoID: videoID,
                                                Constants.YouTubeResponseKeys.Title: videoTitle,
                                                Constants.YouTubeResponseKeys.ThumbnailURL: videoThumbnailURL] as? [String : String]
                        
                        
                    
                        
                
                
                    completion(videoDetailsDict, nil)
                    //}
                    
                }
                
            } else {
                completion(nil, error)
            }
        })
        
        
    }
    
    func fetchUserPlaylists (accessToken: String!, completion: @escaping (_ result: [[String:String]]?, _ error: Error?) -> Void) {
        
        
        let method = Constants.YouTubeMethod.PlaylistMethod
        
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.Mine : Constants.YoutubeParameterValues.MineValue,
                          Constants.YouTubeParameterKeys.MaxResults: Constants.YoutubeParameterValues.MaxResults,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (result, error) in
            if error == nil {
                
                if let result = result {
                    let playlistsArray = result[Constants.YouTubeResponseKeys.Items] as! [[String:Any]]
                    var playlists : [[String:String]] = []
                    
                    
                    for index in 0 ... playlistsArray.count-1 {
                        
                        let playlist = playlistsArray[index] as [String: Any]
                        let playlistSnippetDict = playlist[Constants.YouTubeResponseKeys.Snippet] as? [String:Any]
                        let playlistID = playlist[Constants.YouTubeResponseKeys.PlaylistID] as? String
                        let playlistTitle = playlistSnippetDict![Constants.YouTubeResponseKeys.Title] as? String
                        let thumbnailURL = ((playlistSnippetDict![Constants.YouTubeResponseKeys.Thumbnails] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailKeys.Default] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailURL] as? String
                        
                        let playlistDict = [Constants.YouTubeResponseKeys.PlaylistID : playlistID ,
                                            Constants.YouTubeResponseKeys.Title : playlistTitle,
                                            Constants.YouTubeResponseKeys.ThumbnailURL :  thumbnailURL]
                        
                        
                        playlists.append(playlistDict as! [String : String])
                        
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
    
    
    
    func searchForVideo(searchQuery: String, completion: @escaping (_ result: [[String : String]]?, _ error: Error?) -> Void ) {
        
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
                    
                    var videosArray = result[Constants.YouTubeResponseKeys.Items] as! [[String:Any]]
                    var videos : [[String:String]] = []
                    
                    
                    for index in 0 ... videosArray.count-1 {
                        let videoDict = videosArray[index]  as [String: Any]
                        let snippetDict = videoDict[Constants.YouTubeResponseKeys.Snippet] as? [String:Any]
                        let videoID = (videoDict["id"] as! [String:Any])[Constants.YouTubeResponseKeys.VideoID] as? String
                        let videoTitle = snippetDict![Constants.YouTubeResponseKeys.Title] as? String
                        let videoThumbnailURL = ((snippetDict![Constants.YouTubeResponseKeys.Thumbnails] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailKeys.Default] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailURL] as? String
                        
                        
                        
                        let videoDetailsDict = [Constants.YouTubeResponseKeys.VideoID : videoID!,
                                                Constants.YouTubeResponseKeys.Title: videoTitle!,
                                                Constants.YouTubeResponseKeys.ThumbnailURL: videoThumbnailURL!]
                        
                        
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
    
    
    func getVideosFromPlaylist(accessToken: String?, playlist: Playlist?, completion: @escaping (_ result: [[String: String]]?, _ error: Error?) -> Void) {
        
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        
        let parameters = [Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken!,
                          Constants.YouTubeParameterKeys.PlaylistID: playlist?.id,
                          Constants.YouTubeParameterKeys.MaxResults : Constants.YoutubeParameterValues.MaxResults]
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (result, error) in
            
            if error == nil {
                if let result = result {
                    
                    
                    
                    var videosArray = result[Constants.YouTubeResponseKeys.Items] as! [[String:Any]]
                    var videos : [[String:String]] = []
                    
                    for index in 0 ... videosArray.count-1 {
                        
                        let videoDict = videosArray[index] as [String: Any]
                        let snippetDict = videoDict[Constants.YouTubeResponseKeys.Snippet] as? [String:Any]
                        let playlistItemID = videoDict[Constants.YouTubeResponseKeys.PlaylistItemID] as? String
                        let videoID = (snippetDict![Constants.YouTubeResponseKeys.ResourceID] as! [String:Any])[Constants.YouTubeResponseKeys.VideoID] as? String
                        
                        let videoTitle = snippetDict![Constants.YouTubeResponseKeys.Title] as? String
                        
                        /*guard videoTitle != "Deleted video" else {
                            print("This video has been deleted from youTube")
                            //delete video from playlist
                            //self.deleteVideoFromYTPlaylist(playlistItemID: playlistItemID!, accessToken: accessToken!, completion: nil)
                            return
                        }
                        
                        guard videoTitle != "Private Video" else {
                            print("This video is private")
                            //delete video from playlist
                            //self.deleteVideoFromYTPlaylist(playlistItemID: playlistItemID!, accessToken: accessToken!, completion: nil)
                            return
                        }*/
                        
                        //let thumbnails = snippetDict![Constants.YouTubeResponseKeys.Thumbnails] as? [String: Any]
                        
                        //guard thumbnails != nil else {
                        //     print("Video Thumbnail is unavailable")
                        //     return
                        // }
                        /*
                        guard snippetDict![Constants.YouTubeResponseKeys.Thumbnails] != nil else {
                            print("Video Thumbnail is unavailable")
                            return
                        }*/
                        if videoTitle != "Private video" && videoTitle != "Deleted video" {
                        
                        let videoThumbnailURL = ((snippetDict![Constants.YouTubeResponseKeys.Thumbnails] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailKeys.Default] as! [String: Any])[Constants.YouTubeResponseKeys.ThumbnailURL] as? String
                        
                        
                        
                        
                        let videoDetailsDict = [Constants.YouTubeResponseKeys.PlaylistItemID : playlistItemID,
                                                Constants.YouTubeResponseKeys.VideoID: videoID,
                                                Constants.YouTubeResponseKeys.Title: videoTitle,
                                                Constants.YouTubeResponseKeys.ThumbnailURL: videoThumbnailURL]
                        
                        
                        videos.append(videoDetailsDict as! [String : String])
                        }
                    }
                    OperationQueue.main.addOperation {
                        
                        completion(videos, nil)
                    }
                    
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil, error)
                }
            }
            
        }
        
    }
    
    
    
    
    
    func deleteVideoFromYTPlaylist(playlistItemID: String, accessToken: String, completion: @escaping (_ success: Bool) -> Void){
        let method = Constants.YouTubeMethod.PlaylistItemsMethod
        let parameters = [Constants.YouTubeParameterKeys.AccessToken: accessToken,
                          Constants.YouTubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.PlaylistItemID: playlistItemID]
        
        _ = YoutubeAPI.sharedInstance().taskForDELETEMethod(method: method, parameters: parameters as [String : AnyObject]) { (success, error) in
            if error == nil {
                print("video deleted from playlist")
                completion(true)
            } else {
                print("video could not be deleted")
                completion(false)
            }
            
        }
    }
    
    func createPlaylist(accessToken: String!, title: String!, privacyOption: String!, completion: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        
        
        let method = Constants.YouTubeMethod.PlaylistMethod
        let parameters = [Constants.YouTubeParameterKeys.Part : "snippet,status",
                          Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        struct RequestBody: Codable {
            let snippet: Snippet
            let status: Status
        }
        
        struct Snippet: Codable {
            let title: String
        }
        
        struct Status: Codable {
            let privacyStatus: String
        }
        
        
        
      
        let snippet = Snippet(title: title!)
        let status = Status(privacyStatus: privacyOption!)
      
        let jsonBody = RequestBody(snippet: snippet, status: status)
       
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do{
        let jsonData = try? jsonEncoder.encode(jsonBody)
            
        
        
        _ = YoutubeAPI.sharedInstance().taskForPOSTMethod(method: method, bodyParameters: parameters as [String : AnyObject], jsonBody: jsonData!, completionHandlerForPOST: { (result, error) in
            
            if error == nil {
                print("Playlist created")
                
                completion(result, nil)
                
            } else {
                //print(error?.localizedDescription)
                
                completion(nil, error)
                
                
            }
        })
        } catch {
            
        }
        
    }
    
    
}


