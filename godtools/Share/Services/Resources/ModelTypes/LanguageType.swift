//
//  LanguageType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageType: Codable {
    
    associatedtype Attributes: LanguageAttributesType
    
    var id: String { get }
    var type: String { get }
    var attributes: Attributes? { get }
}
