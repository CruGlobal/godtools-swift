//
//  GodToolsLanguage+CoreDataProperties.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/17/16.
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

}
