//
//  DownloadedResource+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension DownloadedResource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedResource> {
        return NSFetchRequest<DownloadedResource>(entityName: "DownloadedResource");
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var translations: NSSet?
    @NSManaged public var pages: NSSet?

}

// MARK: Generated accessors for translations
extension DownloadedResource {

    @objc(addTranslationsObject:)
    @NSManaged public func addToTranslations(_ value: Translation)

    @objc(removeTranslationsObject:)
    @NSManaged public func removeFromTranslations(_ value: Translation)

    @objc(addTranslations:)
    @NSManaged public func addToTranslations(_ values: NSSet)

    @objc(removeTranslations:)
    @NSManaged public func removeFromTranslations(_ values: NSSet)

}

// MARK: Generated accessors for pages
extension DownloadedResource {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageFile)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageFile)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}
