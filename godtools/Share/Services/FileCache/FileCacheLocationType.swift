//
//  FileCacheLocationType.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FileCacheLocationType {
    
    var directory: String { get }
    var filename: String { get }
    var fileExtension: String? { get }
}

extension FileCacheLocationType {
    
    var directoryUrl: URL? {
        return URL(string: directory)
    }

    var fileUrl: URL? {
        
        var fileUrl: URL? = directoryUrl?.appendingPathComponent(filename)
        
        if let fileExtension = fileExtension {
            fileUrl = fileUrl?.appendingPathExtension(fileExtension)
        }
        
        return fileUrl
    }
}
