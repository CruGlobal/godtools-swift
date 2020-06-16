//
//  RealmSHA256File+FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension RealmSHA256File {
    
    var location: SHA256FileLocation {
        return SHA256FileLocation(sha256: sha256, pathExtension: pathExtension)
    }
}
