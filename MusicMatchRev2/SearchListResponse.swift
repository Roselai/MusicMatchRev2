//
//  SearchListResponse.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 10/22/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation

struct SearchListResponse: Codable {
    let kind : String
    let etag : String
    let nextPageToken : String
    let prevPageToken : String
    let regionCode : String
    let pageInfo : PageInfo
    let items : [Item]
    
    struct PageInfo: Codable {
        let totalResults : Int
        let resultsPerPage : Int
    }
    
    struct Item: Codable {
        let kind : String
        let etag : String
        let id : Id
        let snippet: Snippet
        
        
        struct Id: Codable {
            let kind : String
            let videoId : String
            let channelId : String
            let playlistId : String
        }
        
        struct Snippet: Codable {
            let publishedAt : Date
            let channelId : String
            let title : String
            let description : String
            let thumbnails : Thumbnails
            let channelTitle : String
            let liveBroadcastContent : String
            
            struct Thumbnails : Codable {
                let key : Key
                
                struct Key: Codable {
                let url : String
                let width : UInt
                let height : UInt
                }
                
            }
        }
    }
}

