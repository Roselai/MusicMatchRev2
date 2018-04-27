//
//  SpotifyClient.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 3/28/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

class SpotifyClient{
    
    // shared session
    var session = URLSession.shared
 
    
    func taskForGETMethod(method: String?, parameters: [String: AnyObject]?, accessToken: String?, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var newMethod: String!
        
        /*if parameters != nil {
        for (key,value) in parameters! {
            newMethod = subtituteKeyInMethod(method: method!, key: key, value: value as! String)
            }
        } else {
            newMethod = method
        }*/
        
        /* 2/3. Build the URL, Configure the request */
        let url = SpotifyClient.SpotifyURLFromParameters(method: method!, parameters: parameters)
        var request = URLRequest(url: url)
        
        
        request.setValue(("Bearer \(accessToken!)"), forHTTPHeaderField: "Authorization")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            let errorString = error?.localizedDescription
            guard (error == nil) else {
                //sendError("There was an error with your request")
                sendError(error: "Your request could not be completed: \(errorString!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(jsonData: data, completionHandlerForConvertData: completionHandlerForGET )
            //completionHandlerForGET(data, nil)
            
        }
        
        
        /* 7. Start the request */
        task.resume()
        
        return task
        
    }
    
    
   
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(jsonData: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        /*let decoder = JSONDecoder()
        let playlists = try? decoder.decode(CurrentUserPlaylists.self, from: jsonData)
        */
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(jsonData)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        
        completionHandlerForConvertData(parsedResult as AnyObject, nil)
    }
    
   /*
    struct CurrentUserPlaylists: Decodable {
        let href : String
        let items : [SpotifyPlaylist]
        
        struct SpotifyPlaylist: Decodable {
            
        }*/
    
 
    
    
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    
    
    
    // MARK: Helper for Creating a URL from Parameters
    
     static func SpotifyURLFromParameters(method: String, parameters: [String:AnyObject]?) -> URL {
        
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        components.scheme = Constants.Spotify.APIScheme
        components.host = Constants.Spotify.APIHost
        components.path = Constants.Spotify.APIPath + method
        
        
        /*let baseParams = [Constants.YouTubeParameterKeys.Part : Constants.YoutubeParameterValues.partValue]
         
         for (key, value) in baseParams {
         let item = URLQueryItem(name: key, value: value)
         queryItems.append(item)
         
         }*/
        
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value as? String)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems as [URLQueryItem]?
        return components.url!
    }
    
    func downloadimageData(photoURL: URL, completionHandlerForDownloadImageData: @escaping (_ data: Data?, _ error: NSError?)-> Void) -> URLSessionDataTask {
        
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDownloadImageData(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            let errorString = error?.localizedDescription
            guard (error == nil) else {
                //sendError("There was an error with your request")
                sendError(error: "Your request could not be completed: \(errorString!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            completionHandlerForDownloadImageData(data, nil)
        }
        task.resume()
        return task
    }
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SpotifyClient {
        struct Singleton {
            static var sharedInstance = SpotifyClient()
        }
        return Singleton.sharedInstance
    }
    
}
