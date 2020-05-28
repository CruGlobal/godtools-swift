//
//  LanguageAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageAttributesType: Codable {
    
    var code: String? { get }
    var name: String? { get }
    var direction: String? { get }
}
