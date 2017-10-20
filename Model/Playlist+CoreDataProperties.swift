//
//  Playlist+CoreDataProperties.swift
//  
//
//  Created by Shukti Shaikh on 10/18/17.
//
//

import Foundation
import CoreData


extension Playlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension Playlist {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Video)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Video)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
