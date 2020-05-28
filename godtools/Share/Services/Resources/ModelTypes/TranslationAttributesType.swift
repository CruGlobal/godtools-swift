//
//  TranslationAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationAttributesType: Codable {
    
    var isPublished: Bool { get }
    var manifestName: String? { get }
    var translatedDescription: String? { get }
    var translatedName: String? { get }
    var translatedTagline: String? { get }
    var version: Int { get }
}
