//
//  DownloadedResource+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension DownloadedResource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedResource> {
        return NSFetchRequest<DownloadedResource>(entityName: "DownloadedResource");
    }

    @NSManaged public var bannerRemoteId: String?
    @NSManaged public var code: String?
    @NSManaged public var copyrightDescription: String?
    @NSManaged public var myViews: Int32
    @NSManaged public var name: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var shouldDownload: Bool
    @NSManaged public var totalViews: Int32
    @NSManaged public var translations: NSSet?

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
