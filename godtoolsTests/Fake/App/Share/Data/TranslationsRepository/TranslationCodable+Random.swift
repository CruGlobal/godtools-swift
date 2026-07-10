//
//  TranslationCodable+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension TranslationCodable {

    static func random(
        id: String = UUID().uuidString,
        isPublished: Bool = Bool.random(),
        language: LanguageCodable? = nil,
        manifestName: String = String.random(),
        resource: ResourceCodable? = nil,
        toolDetailsBibleReferences: String = String.random(),
        toolDetailsConversationStarters: String = String.random(),
        toolDetailsOutline: String = String.random(),
        translatedDescription: String = String.random(),
        translatedName: String = String.random(),
        translatedTagline: String = String.random(),
        type: String = String.random(),
        version: Int = Int.random()
    ) -> TranslationCodable {

        return TranslationCodable(
            id: id,
            isPublished: isPublished,
            language: language,
            manifestName: manifestName,
            resource: resource,
            toolDetailsBibleReferences: toolDetailsBibleReferences,
            toolDetailsConversationStarters: toolDetailsConversationStarters,
            toolDetailsOutline: toolDetailsOutline,
            translatedDescription: translatedDescription,
            translatedName: translatedName,
            translatedTagline: translatedTagline,
            type: type,
            version: version
        )
    }
}
