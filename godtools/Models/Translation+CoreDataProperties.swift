//
//  Translation+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension Translation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Translation> {
        return NSFetchRequest<Translation>(entityName: "Translation");
    }

    @NSManaged public var isDownloaded: Bool
    @NSManaged public var isPublished: Bool
    @NSManaged public var localizedDescription: String?
    @NSManaged public var localizedName: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var version: Int16
    @NSManaged public var downloadedResource: DownloadedResource?
    @NSManaged public var language: Language?

}
