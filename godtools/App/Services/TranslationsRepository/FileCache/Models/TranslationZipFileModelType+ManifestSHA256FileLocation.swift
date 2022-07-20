//
//  TranslationZipFileModelType+ManifestSHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // This should be removed in place of TranslationsRepository following GT-1448. ~Levi
extension TranslationZipFileModelType {
    var manifestSHA256FileLocation: SHA256FileLocation {
        if translationManifestFilename.contains(".xml") {
            return SHA256FileLocation(sha256WithPathExtension: translationManifestFilename)
        }
        else {
            return SHA256FileLocation(sha256: translationManifestFilename, pathExtension: "xml")
        }
    }
}
