//
//  ResourcesCacheSyncInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ResourcesCacheSyncInterface {
    
    func syncResources(
        resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable,
        shouldRemoveDataThatNoLongerExists: Bool
    ) async throws -> ResourcesCacheSyncResult
}
