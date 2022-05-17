//
//  BaseToolSettingsChooseLanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseToolSettingsChooseLanguageViewModel: ObservableObject {
    
    @Published var primaryLanguageTitle: String = ""
    @Published var parallelLanguageTitle: String = ""
    
    init() {}
    
    func primaryLanguageTapped() {}
    func parallelLanguageTapped() {}
    func swapLanguageTapped() {}
}
