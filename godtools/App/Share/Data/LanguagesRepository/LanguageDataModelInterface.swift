//
//  LanguageDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol LanguageDataModelInterface {
    
    var code: BCP47LanguageIdentifier { get }
    var directionString: String { get }
    var id: String { get }
    var name: String { get }
    var type: String { get }
    var forceLanguageName: Bool { get }
}
