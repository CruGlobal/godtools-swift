//
//  DownloadedLanguageModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageModel: DownloadedLanguageModelType {
    
    let languageId: String
    
    init(model: DownloadedLanguageModelType) {
        
        languageId = model.languageId
    }
}
