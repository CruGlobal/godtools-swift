//
//  DeleteLanguageListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeleteLanguageListItemViewModel: BaseLanguagesListItemViewModel {
    
    override init() {
        
        super.init()
        
        self.name = "None"
        self.isSelected = false
    }
}
