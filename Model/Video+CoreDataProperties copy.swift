//
//  Video+CoreDataProperties.swift
//  
//
//  Created by Shukti Shaikh on 10/18/17.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var thumbnail: NSData?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var title: String?
    @NSManaged public var videoID: String?
    @NSManaged public var playlists: NSSet?

}

// MARK: Generated accessors for playlists
extension Video {

    @objc(addPlaylistsObject:)
    @NSManaged public func addToPlaylists(_ value: Playlist)

    @objc(removePlaylistsObject:)
    @NSManaged public func removeFromPlaylists(_ value: Playlist)

    @objc(addPlaylists:)
    @NSManaged public func addToPlaylists(_ values: NSSet)

    @objc(removePlaylists:)
    @NSManaged public func removeFromPlaylists(_ values: NSSet)

}
