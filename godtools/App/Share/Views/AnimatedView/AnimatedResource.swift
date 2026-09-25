//
//  AnimatedResource.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum AnimatedResource: Hashable, Sendable {
    
    case deviceFileManagerfilepathJsonFile(filepath: String)
    case mainBundleJsonFile(filename: String)
}
