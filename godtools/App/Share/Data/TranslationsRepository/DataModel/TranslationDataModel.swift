//
//  TranslationDatainterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct TranslationDataModel {
    
    let id: String
    let isPublished: Bool
    let languageDataModel: LanguageDataModel?
    let manifestName: String
    let resourceDataModel: ResourceDataModel?
    let toolDetailsBibleReferences: String
    let toolDetailsConversationStarters: String
    let toolDetailsOutline: String
    let translatedDescription: String
    let translatedName: String
    let translatedTagline: String
    let type: String
    let version: Int
}

extension TranslationDataModel: Equatable {
    static func == (this: TranslationDataModel, that: TranslationDataModel) -> Bool {
        return this.id == that.id
    }
}
