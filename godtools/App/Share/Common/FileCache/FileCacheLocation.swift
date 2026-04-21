//
//  FileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct FileCacheLocation: Sendable {
    
    let relativeUrlString: String

    var directoryUrl: URL? {

        guard let fileUrl = self.fileUrl, fileUrl.pathComponents.count > 1 else {
            return nil
        }

        guard let lastPathComponent = fileUrl.pathComponents.last, !lastPathComponent.isEmpty else {
            return nil
        }
            
        let directoryPath: String = fileUrl.absoluteString.replacingOccurrences(of: "/" + lastPathComponent, with: "")
        
        return URL(string: directoryPath)
    }
    
    var fileUrl: URL? {
        return URL(string: relativeUrlString)
    }
    
    var filenameWithPathExtension: String? {
        return fileUrl?.lastPathComponent
    }
}
