//
//  BaseToolSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseToolSettingsViewModel: ObservableObject {
    
    init() {}
    
    func getTopBarViewModel() -> BaseToolSettingsTopBarViewModel {
        return BaseToolSettingsTopBarViewModel()
    }
    
    func getOptionsViewModel() -> BaseToolSettingsOptionsViewModel {
        return BaseToolSettingsOptionsViewModel()
    }
    
    func getChooseLanguageViewModel() -> BaseToolSettingsChooseLanguageViewModel {
        return BaseToolSettingsChooseLanguageViewModel()
    }
    
    func getShareablesViewModel() -> ToolSettingsShareablesViewModel {
        return ToolSettingsShareablesViewModel(shareables: [])
    }
}
