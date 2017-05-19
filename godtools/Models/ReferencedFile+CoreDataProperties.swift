//
//  ReferencedFile+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension ReferencedFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReferencedFile> {
        return NSFetchRequest<ReferencedFile>(entityName: "ReferencedFile");
    }

    @NSManaged public var filename: String?
    @NSManaged public var translations: NSSet?

}

// MARK: Generated accessors for translations
extension ReferencedFile {

    @objc(addTranslationsObject:)
    @NSManaged public func addToTranslations(_ value: Translation)

    @objc(removeTranslationsObject:)
    @NSManaged public func removeFromTranslations(_ value: Translation)

    @objc(addTranslations:)
    @NSManaged public func addToTranslations(_ values: NSSet)

    @objc(removeTranslations:)
    @NSManaged public func removeFromTranslations(_ values: NSSet)

}
