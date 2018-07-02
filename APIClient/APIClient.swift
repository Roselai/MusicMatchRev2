//
//  APIClient.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 6/8/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

class APIClient{
    
    // shared session
    var session = URLSession.shared
    
    
    
    func taskForGETMethod(url: URL, parameters: [String: AnyObject]?, accessToken: String? = nil, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        
        
        /* 2/3. Build the URL, Configure the request */
        var request = URLRequest(url: url)
        
        if accessToken != nil {
        request.setValue(("Bearer \(accessToken!)"), forHTTPHeaderField: "Authorization")
        }
        
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
    
    // MARK: POST
    
    func taskForPOSTMethod(url: URL, bodyParameters: [String: AnyObject]?, jsonBody: Data? ,completionHandlerForPOST:@escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        /* 2/3. Build the URL, Configure the request */
        //let url = YoutubeAPI.YoutubeURLFromParameters(method: method, parameters: bodyParameters)
        var request = URLRequest(url: url)
        
        
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            let errorString = error.debugDescription
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request: \(errorString)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            let httpURLResponse = response as! HTTPURLResponse
            let statusCode = httpURLResponse.statusCode
            let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            guard statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!,\(statusCode) \(localizedResponse) " )
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            self.convertDataWithCompletionHandler(jsonData: data, completionHandlerForConvertData: completionHandlerForPOST )
            // completionHandlerForPOST(data, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Delete
    
    func taskForDELETEMethod(url: URL, parameters: [String: AnyObject]?, completionHandlerForDELETE:@escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        /* 2/3. Build the URL, Configure the request */
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
                sendError(error: "There was an error with your DELETE request: \(errorString!)")
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
    
  
    
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
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
    
    class func sharedInstance() -> APIClient {
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        return Singleton.sharedInstance
    }
    
}
