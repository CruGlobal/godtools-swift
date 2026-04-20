//
//  DownloadedTranslationDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DownloadedTranslationDataModel {
    
    let id: String
    let languageId: String
    let manifestAndRelatedFilesPersistedToDevice: Bool
    let resourceId: String
    let translationId: String
    let version: Int
}
