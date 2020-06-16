//
//  LanguageSettingsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageSettingsCacheType {
    
    var primaryLanguageId: ObservableValue<String?> { get }
    var parallelLanguageId: ObservableValue<String?> { get }
    
    func cachePrimaryLanguageId(languageId: String)
    func cacheParallelLanguageId(languageId: String)
    func deletePrimaryLanguageId()
    func deleteParallelLanguageId()
    func getPrimaryLanguage(complete: @escaping ((_ language: LanguageModel?) -> Void))
    func getParallelLanguage(complete: @escaping ((_ language: LanguageModel?) -> Void))
}
