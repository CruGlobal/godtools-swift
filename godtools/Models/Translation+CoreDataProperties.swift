//
//  Translation+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension Translation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Translation> {
        return NSFetchRequest<Translation>(entityName: "Translation");
    }

    @NSManaged public var isDownloaded: Bool
    @NSManaged public var isPublished: Bool
    @NSManaged public var localizedDescription: String?
    @NSManaged public var localizedName: String?
    @NSManaged public var manifestFilename: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var version: Int16
    @NSManaged public var downloadedResource: DownloadedResource?
    @NSManaged public var language: Language?
    @NSManaged public var referencedFiles: NSSet?
    @NSManaged public var attachments: NSSet?

}

// MARK: Generated accessors for referencedFiles
extension Translation {

    @objc(addReferencedFilesObject:)
    @NSManaged public func addToReferencedFiles(_ value: ReferencedFile)

    @objc(removeReferencedFilesObject:)
    @NSManaged public func removeFromReferencedFiles(_ value: ReferencedFile)

    @objc(addReferencedFiles:)
    @NSManaged public func addToReferencedFiles(_ values: NSSet)

    @objc(removeReferencedFiles:)
    @NSManaged public func removeFromReferencedFiles(_ values: NSSet)

}

// MARK: Generated accessors for attachments
extension Translation {

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: Attachment)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: Attachment)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)

}
