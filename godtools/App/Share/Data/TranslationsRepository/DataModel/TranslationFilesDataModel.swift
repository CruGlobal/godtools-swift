//
//  TranslationFilesDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct TranslationFilesDataModel: Sendable {
    
    let files: [FileCacheLocation]
    let translation: TranslationDataModel
}
