//
//  PlaylistStore.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/24/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum PlaylistsResult {
    case success([Playlist])
    case failure(Error)
}

enum VideosResult {
    case success([Video])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}
enum PhotoError: Error {
    case imageCreationError
}

class PlaylistStore {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    func fetchMyPlaylists(accessToken: String, completion: @escaping (PlaylistsResult) -> Void) {
        
        let method = Constants.YouTubeMethod.PlaylistMethod
        
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.Mine : Constants.YoutubeParameterValues.MineValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (data, error) in
            
            var result = self.processPlaylistsRequest(data: data as? Data , error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
            OperationQueue.main.addOperation {
            completion(result)
            }
        })
    }
    
    
    
    private func processPlaylistsRequest(data: Data?, error: Error?) -> PlaylistsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return YoutubeAPI.playlists(fromJSON: jsonData, into: persistentContainer.viewContext)
       
    }
    
    func fetchImage(for playlist: Playlist, completion: @escaping (ImageResult) -> Void) {
        
        guard let thumbnailURLString = playlist.thumnailURL else {
            preconditionFailure("Playlist expected to have thumbnail URL")
        }
        
        if let image = UIImage(data: playlist.thumbnail! as Data) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
        }
        
        
        let photoURL = URL(string: thumbnailURLString)
        
        _ = YoutubeAPI.sharedInstance().downloadimageData(photoURL: photoURL!) { (data, error) in
            
            let result = self.processImageRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
            completion(result)
            }
        }
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    func fetchAllPlaylists(completion: @escaping (PlaylistsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Playlist.id),
                                               ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPlaylists = try viewContext.fetch(fetchRequest)
                completion(.success(allPlaylists))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Videos
    
    func fetchVideos(accessToken: String, searchQueryString: String, completion: @escaping (VideosResult) -> Void) {
        
        let parameters = [Constants.YouTubeParameterKeys.type : Constants.YoutubeParameterValues.typeValue,
                          Constants.YouTubeParameterKeys.Order : Constants.YoutubeParameterValues.orderValue,
                          Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.MaxResults : "\(Constants.YoutubeParameterValues.ResultLimit)",
            Constants.YouTubeParameterKeys.APIKey : Constants.YoutubeParameterValues.APIKey,
            "q": searchQueryString]
        
        let method = Constants.YouTubeMethod.SearchMethod
        
        
        _ =  YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject]) { (data, error) in
            
            var result = self.processVideosRequest(data: data as? Data , error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
            
            
        }
    }
        
        private func processVideosRequest(data: Data?, error: Error?) -> VideosResult {
            guard let jsonData = data else {
                return .failure(error!)
            }
            return YoutubeAPI.videos(fromJSON: jsonData, into: persistentContainer.viewContext)
        }
        
        
       /* let method = Constants.YouTubeMethod.PlaylistMethod
        
        let parameters = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue,
                          Constants.YouTubeParameterKeys.Mine : Constants.YoutubeParameterValues.MineValue,
                          Constants.YouTubeParameterKeys.AccessToken: accessToken]
        
        
        _ = YoutubeAPI.sharedInstance().taskForGETMethod(method: method, parameters: parameters as [String : AnyObject], completionHandlerForGET: { (data, error) in
            
            var result = self.processPlaylistsRequest(data: data as? Data , error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        })*/
 
    
    
}
