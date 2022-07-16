//
//  FileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class FileCacheLocation {
    
    let directory: String
    let filename: String
    let filePathExtension: String?
    
    init(directory: String, filename: String, filePathExtension: String) {
        
        self.directory = directory
        self.filename = filename
        self.filePathExtension = filePathExtension
    }
    
    var directoryUrl: URL? {
        return URL(string: directory)
    }

    var fileUrl: URL? {
        
        guard let fileUrl = directoryUrl?.appendingPathComponent(filename) else {
            return nil
        }
        
        guard let filePathExtension = filePathExtension else {
            return fileUrl
        }
        
        return fileUrl.appendingPathExtension(filePathExtension)
    }
}
