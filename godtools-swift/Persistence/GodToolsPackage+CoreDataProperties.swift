//
//  GodToolsPackage+CoreDataProperties.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/31/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData 

extension GodToolsPackage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GodToolsPackage> {
        return NSFetchRequest<GodToolsPackage>(entityName: "GodToolsPackage");
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var iconFilename: String?
    @NSManaged public var configFilename: String?
    @NSManaged public var status: String?
    @NSManaged public var majorVersion: Int16
    @NSManaged public var minorVersion: Int16
    @NSManaged public var language: GodToolsLanguage?

}
