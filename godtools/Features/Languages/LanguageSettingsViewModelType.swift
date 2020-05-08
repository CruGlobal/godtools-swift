//
//  LanguageSettingsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageSettingsViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var primaryLanguageButtonTitle: ObservableValue<String> { get }
    var parallelLanguageButtonTitle: ObservableValue<String> { get }
    
    func pageViewed()
    func choosePrimaryLanguageTapped()
    func chooseParallelLanguageTapped()
}
