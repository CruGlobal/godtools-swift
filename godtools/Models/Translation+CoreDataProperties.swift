//
//  Translation+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension Translation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Translation> {
        return NSFetchRequest<Translation>(entityName: "Translation");
    }

    @NSManaged public var localizedDescription: String?
    @NSManaged public var localizedName: String?
    @NSManaged public var version: Int16
    @NSManaged public var language: Language?
    @NSManaged public var pageFiles: NSSet?
    @NSManaged public var downloadedResource: DownloadedResource?

}

// MARK: Generated accessors for pageFiles
extension Translation {

    @objc(addPageFilesObject:)
    @NSManaged public func addToPageFiles(_ value: PageFile)

    @objc(removePageFilesObject:)
    @NSManaged public func removeFromPageFiles(_ value: PageFile)

    @objc(addPageFiles:)
    @NSManaged public func addToPageFiles(_ values: NSSet)

    @objc(removePageFiles:)
    @NSManaged public func removeFromPageFiles(_ values: NSSet)

}
