//
//  GodToolsLanguage+CoreDataProperties.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData

extension GodToolsLanguage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GodToolsLanguage> {
        return NSFetchRequest<GodToolsLanguage>(entityName: "GodToolsLanguage");
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var packages: NSSet?

}

// MARK: Generated accessors for packages
extension GodToolsLanguage {

    @objc(addPackagesObject:)
    @NSManaged public func addToPackages(_ value: GodToolsPackage)

    @objc(removePackagesObject:)
    @NSManaged public func removeFromPackages(_ value: GodToolsPackage)

    @objc(addPackages:)
    @NSManaged public func addToPackages(_ values: NSSet)

    @objc(removePackages:)
    @NSManaged public func removeFromPackages(_ values: NSSet)

}
