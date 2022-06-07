//
//  BaseToolSettingsShareablesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseToolSettingsShareablesViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var numberOfItems: Int = 0
    
    init() {}
    
    func getShareableItemViewModel(index: Int) -> BaseToolSettingsShareableItemViewModel {
        return BaseToolSettingsShareableItemViewModel()
    }
    
    func shareableTapped(index: Int) {}
}
