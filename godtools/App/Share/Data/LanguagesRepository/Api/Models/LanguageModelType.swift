//
//  LanguageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageModelType {
    
    var code: BCP47LanguageIdentifier { get }
    var direction: String { get }
    var id: String { get }
    var name: String { get }
    var type: String { get }
}
