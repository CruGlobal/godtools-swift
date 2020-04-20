//
//  LanguageSettingsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageSettingsCacheType {
    
    var primaryLanguageId: String? { get }
    var parallelLanguageId: String? { get }
    
    func cachePrimaryLanguageId(language: Language)
    func cacheParallelLanguageId(language: Language)
    func deletePrimaryLanguageId()
    func deleteParallelLanguageId()
}
