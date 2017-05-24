//
//  Attachment+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension Attachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment");
    }

    @NSManaged public var remoteId: String?
    @NSManaged public var sha: String?
    @NSManaged public var isBanner: Bool
    @NSManaged public var translations: Translation?
    @NSManaged public var resource: DownloadedResource?

}
