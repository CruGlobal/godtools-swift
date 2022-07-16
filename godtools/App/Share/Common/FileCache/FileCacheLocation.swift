//
//  FileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct FileCacheLocation: FileCacheLocationType {
    
    let directory: String
    let filename: String
    let filePathExtension: String?
    
    init(directory: String, filename: String, filePathExtension: String) {
        
        self.directory = directory
        self.filename = filename
        self.filePathExtension = filePathExtension
    }
}
