//
//  TranslationZipFileModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationZipFileModelType {
        
    associatedtype SHA256Files = Sequence
    
    var translationId: String { get }
    var resourceId: String { get }
    var languageId: String { get }
    var languageCode: String { get } // bcp47 language tag
    var translationManifestFilename: String { get }
    var translationsVersion: Int { get }
    var sha256Files: SHA256Files { get }
}
