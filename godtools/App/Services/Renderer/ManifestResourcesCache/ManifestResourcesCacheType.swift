//
//  ManifestResourcesCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ManifestResourcesCacheType {
    
    init(manifest: MobileContentManifestType, translationsFileCache: TranslationsFileCache)
    
    func getImageFromManifestResources(fileName: String) -> UIImage?
}
