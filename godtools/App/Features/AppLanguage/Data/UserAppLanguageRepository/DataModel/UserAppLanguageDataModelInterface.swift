//
//  UserAppLanguageDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol UserAppLanguageDataModelInterface {
    
    var id: String { get }
    var languageId: BCP47LanguageIdentifier { get }
}
