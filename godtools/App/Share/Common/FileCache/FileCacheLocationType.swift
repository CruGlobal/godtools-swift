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
    var filePathExtension: String? { get }
}

extension FileCacheLocationType {
    
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
