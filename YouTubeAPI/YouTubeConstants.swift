//
//  YouTubeConstants.swift
//  MusicMatch
//
//  Created by Shukti Shaikh on 8/22/17.
//  Copyright © 2017 Shukti Shaikh. All rights reserved.
//

import Foundation

// MARK: - Constants

struct Constants {
    
    // MARK: YouTube
    struct YouTube {
        static let APIScheme = "https"
        static let APIHost = "www.googleapis.com"
        static let APIPath = "/youtube/v3"
    }
    
    struct YouTubeMethod {
        static let SearchMethod = "/search"
        static let PlaylistMethod = "/playlists"
        static let PlaylistItemsMethod = "/playlistItems"
    }
    
    struct YouTubeAuthScopes{
        static let Youtube = "https://www.googleapis.com/auth/youtube"
        static let YouTubeForceSSL = "https://www.googleapis.com/auth/youtube.force-ssl"
        static let YouTubeReadOnly = "https://www.googleapis.com/auth/youtube.readonly"
        static let YouTubeUpload = "https://www.googleapis.com/auth/youtube.upload"
        static let YouTubePartner = "https://www.googleapis.com/auth/youtubepartner"
        static let YouTubePartnerChannelAudit = "https://www.googleapis.com/auth/youtubepartner-channel-audit"
        
    }
    
    
    // MARK: YouTube Parameter Keys
    struct YouTubeParameterKeys {
        static let APIKey = "key"
        static let Part = "part"
        static let Order = "order"
        static let type = "type"
        static let MaxResults = "maxResults"
        static let AccessToken = "access_token"
        static let Mine = "mine"
        static let PlaylistID = "playlistId"
        static let PerPage = "maxResults"
        static let PlaylistItemID = "id"
        static let PageToken = "pageToken"
        static let NextPageToken = "nextPageToken"
    }
    
    // MARK: YouTube Parameter Values
    struct YoutubeParameterValues {
        static let APIKey = "AIzaSyCFdG_4PnnzHyFcNuSLOjFKYUUcTXo9usQ" //browser key
        static let partValue = "snippet"
        static let orderValue = "relevance"
        static let typeValue = "video"
        static let queryTerm = "q"
        static let ResultLimit = 10
        static let MineValue = "true"
        static let PerPage = 50
        static let MaxResults = "50"
        
    }
    
    // MARK: YouTube Response Keys
    struct YouTubeResponseKeys {
        static let Items = "items"
        static let Snippet = "snippet"
        static let PlaylistID = "id"
        static let VideoID = "videoId"
        static let PlaylistItemID = "id"
        static let Title = "title"
        static let Thumbnails = "thumbnails"
        static let Thumbnail = "thumbnail"
        static let ThumbnailURL = "url"
        static let ResourceID = "resourceId"
        static let ContentDetails = "contentDetails"
        static let NextPageToken = "nextPageToken"
        static let VideoPublishedAt = "videoPublishedAt"
        
        struct ThumbnailKeys {
            static let Default = "default"
        }
        
        
        
    }
    
    struct Spotify {
        static let APIScheme = "https"
        static let APIHost = "api.spotify.com"
        static let APIPath = ""
    }
    
    struct SpotifyMethod {
        static let PlaylistMethod = "/v1/me/playlists"
        static let PlaylistItemsMethod = "/v1/users/{user_id}/playlists/{playlist_id}/tracks"
        static let CurrentUserProfileMethod = "/v1/me"
    }

    struct SpotifyParameterKeys {
        static let UserID = "user_id"
        static let PlayListID = "playlist_id"
        
    }
    
}
