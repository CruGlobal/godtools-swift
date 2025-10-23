//
//  TranslationDatainterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct TranslationDataModel: TranslationDataModelInterface {
    
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
    
    init(interface: TranslationDataModelInterface) {
        
        id = interface.id
        isPublished = interface.isPublished
        languageDataModel = interface.languageDataModel
        manifestName = interface.manifestName
        resourceDataModel = interface.resourceDataModel
        toolDetailsBibleReferences = interface.toolDetailsBibleReferences
        toolDetailsConversationStarters = interface.toolDetailsConversationStarters
        toolDetailsOutline = interface.toolDetailsOutline
        translatedDescription = interface.translatedDescription
        translatedName = interface.translatedName
        translatedTagline = interface.translatedTagline
        type = interface.type
        version = interface.version
    }
}

extension TranslationDataModel: Equatable {
    static func == (this: TranslationDataModel, that: TranslationDataModel) -> Bool {
        return this.id == that.id
    }
}
