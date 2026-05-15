//
//  ManifestFile+FileName.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import GodToolsShared

extension ManifestFile {
    
    var fileName: String {
        get throws {
            guard let fileName = src, !fileName.isEmpty else {
                throw NSError.errorWithDescription(description: "Manifest file is missing src.")
            }
            return fileName
        }
    }
}
