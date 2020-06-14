//
//  ResourceSHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourceSHA256FileLocation {
    
    let sha256: String
    let pathExtension: String
    let fileUrl: URL?
    
    init(sha256: String, pathExtension: String) {
        
        self.sha256 = sha256
        self.pathExtension = pathExtension
        self.fileUrl = URL(string: sha256)?.appendingPathExtension(pathExtension)
    }
}
