//
//  PageFile+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension PageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageFile> {
        return NSFetchRequest<PageFile>(entityName: "PageFile");
    }

    @NSManaged public var remoteId: String?
    @NSManaged public var translations: NSSet?

}

// MARK: Generated accessors for translations
extension PageFile {

    @objc(addTranslationsObject:)
    @NSManaged public func addToTranslations(_ value: PageFile)

    @objc(removeTranslationsObject:)
    @NSManaged public func removeFromTranslations(_ value: PageFile)

    @objc(addTranslations:)
    @NSManaged public func addToTranslations(_ values: NSSet)

    @objc(removeTranslations:)
    @NSManaged public func removeFromTranslations(_ values: NSSet)

}
