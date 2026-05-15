//
//  TranslationsCdnInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import GodToolsShared

protocol TranslationsCdnInterface {
    
    func getManifestFile(manifestFile: ManifestFile, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
