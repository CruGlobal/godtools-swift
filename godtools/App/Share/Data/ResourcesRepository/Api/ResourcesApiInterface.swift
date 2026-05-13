//
//  ResourcesApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ResourcesApiInterface {
    
    func getResourcePlusLatestTranslationsAndAttachments(id: String, requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable
    func getResourcePlusLatestTranslationsAndAttachments(abbreviation: String, requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable
    func getResourcesPlusLatestTranslationsAndAttachments(requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable
}
