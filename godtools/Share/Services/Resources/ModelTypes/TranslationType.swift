//
//  TranslationType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationType: Codable {
    
    associatedtype Attributes: TranslationAttributesType
    associatedtype Resource: ResourceType
    associatedtype Language: LanguageType
    
    var id: String { get }
    var type: String { get }
    var attributes: Attributes? { get }
    var resource: Resource? { get }
    var language: Language? { get }
}
