//
//  YoutubeAPI.swift
//  MusicMatch
//
//  Created by Shukti Shaikh on 8/22/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation


class YoutubeAPI{
    
    
    // shared session
    var session = URLSession.shared
    
    
    func taskForGETMethod(method: String, parameters: [String: AnyObject]?, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
     
        
        /* 2/3. Build the URL, Configure the request */
        let url = YoutubeAPI.YoutubeURLFromParameters(method: method, parameters: parameters)
        let request = URLRequest(url: url)
        
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
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerForGET )
            
        }
        
        
        /* 7. Start the request */
        task.resume()
        
        return task
        
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, bodyParameters: [String: AnyObject]?, jsonBody: Data? ,completionHandlerForPOST:@escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
        
        /* 2/3. Build the URL, Configure the request */
        let url = YoutubeAPI.YoutubeURLFromParameters(method: method, parameters: bodyParameters)
        var request = URLRequest(url: url)
        
        
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            let errorString = error?.localizedDescription
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request: \(errorString!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!, \(String(describing: (response as? HTTPURLResponse)?.statusCode)) " )
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForPOST(data as AnyObject, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Delete
    
    func taskForDELETEMethod(method: String, parameters: [String: AnyObject]?, completionHandlerForDELETE:@escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        /* 2/3. Build the URL, Configure the request */
        let url = YoutubeAPI.YoutubeURLFromParameters(method: method, parameters: parameters)
        var request = URLRequest(url: url)
        
        
        request.httpMethod = "DELETE"
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(false, NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            let errorString = error?.localizedDescription
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request: \(errorString!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 204 else {
                sendError(error: "Your request returned a status code other than 204")
                
                return
            }

            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
          completionHandlerForDELETE(true, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    
    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private static func YoutubeURLFromParameters(method: String, parameters: [String:AnyObject]?) -> URL {
        
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        components.scheme = Constants.YouTube.APIScheme
        components.host = Constants.YouTube.APIHost
        components.path = Constants.YouTube.APIPath + method
        
      
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
    
    class func sharedInstance() -> YoutubeAPI {
        struct Singleton {
            static var sharedInstance = YoutubeAPI()
        }
        return Singleton.sharedInstance
}

}
