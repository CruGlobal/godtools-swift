//
//  PageFile+CoreDataProperties.swift
//  godtools
//
//  Created by Ryan Carlson on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData


extension PageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageFile> {
        return NSFetchRequest<PageFile>(entityName: "PageFile");
    }

    @NSManaged public var remoteId: String?
    @NSManaged public var resource: DownloadedResource?

}
