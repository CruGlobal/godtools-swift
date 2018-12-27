//
//  ReferencedFile.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ReferencedFile: Object {
    @objc dynamic var filename = ""
    let translations = List<Translation>()
}
