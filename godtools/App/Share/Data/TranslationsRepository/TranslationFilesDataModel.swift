//
//  TranslationFilesDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct TranslationFilesDataModel {
    
    let translationId: String
    let manifestFileName: String
    let fileCacheLocations: [FileCacheLocation]
}
