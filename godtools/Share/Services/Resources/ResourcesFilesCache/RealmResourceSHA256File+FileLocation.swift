//
//  RealmResourceSHA256File+FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension RealmResourceSHA256File {
    
    var location: ResourceSHA256FileLocation {
        return ResourceSHA256FileLocation(sha256: sha256, pathExtension: pathExtension)
    }
}
