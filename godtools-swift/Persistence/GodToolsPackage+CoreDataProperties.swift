//
//  GodToolsPackage+CoreDataProperties.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData

extension GodToolsPackage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GodToolsPackage> {
        return NSFetchRequest<GodToolsPackage>(entityName: "GodToolsPackage");
    }

    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var language: GodToolsLanguage?

}
