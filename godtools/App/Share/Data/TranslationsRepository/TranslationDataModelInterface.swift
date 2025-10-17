//
//  TranslationDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol TranslationDataModelInterface {
    
    var id: String { get }
    var isPublished: Bool { get }
    var languageDataModel: LanguageDataModel? { get }
    var manifestName: String { get }
    var resourceDataModel: ResourceDataModel? { get }
    var toolDetailsBibleReferences: String { get }
    var toolDetailsConversationStarters: String { get }
    var toolDetailsOutline: String { get }
    var translatedDescription: String { get }
    var translatedName: String { get }
    var translatedTagline: String { get }
    var type: String { get }
    var version: Int { get }
}
