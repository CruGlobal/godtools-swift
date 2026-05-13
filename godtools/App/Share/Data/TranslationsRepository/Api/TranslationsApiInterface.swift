//
//  TranslationsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/8/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol TranslationsApiInterface {
    
    func getTranslationFile(fileName: String, requestPriority: RequestPriority) async throws -> RequestDataResponse
    func getTranslationZipFile(translationId: String, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
