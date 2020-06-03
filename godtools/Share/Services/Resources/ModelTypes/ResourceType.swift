//
//  ResourceType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourceType: Codable {
    
    associatedtype Attributes: ResourceAttributesType
    associatedtype Translations: Sequence
    associatedtype Attachments: Sequence
    
    var id: String { get }
    var type: String { get }
    var attributes: Attributes? { get }
    var latestTranslations: Translations { get }
    var attachments: Attachments { get }
}
