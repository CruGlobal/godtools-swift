//
//  TranslationModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationModelType {
        
    var id: String { get }
    var isPublished: Bool { get }
    var manifestName: String { get }
    var translatedDescription: String { get }
    var translatedName: String { get }
    var translatedTagline: String { get }
    var type: String { get }
    var version: Int { get }
    
    func getResource() -> ResourceModel?
    func getLanguage() -> LanguageModel?
}
