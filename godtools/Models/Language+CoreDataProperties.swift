//
//  Language+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension Language {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Language> {
        return NSFetchRequest<Language>(entityName: "Language");
    }

    @NSManaged public var code: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var shouldDownload: Bool

}
