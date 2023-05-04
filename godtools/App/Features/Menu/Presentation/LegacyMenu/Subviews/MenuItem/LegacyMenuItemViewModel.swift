//
//  LegacyMenuItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LegacyMenuItemViewModel {
    
    let title: String
    let selectionDisabled: Bool
    
    init(title: String, selectionDisabled: Bool) {
        
        self.title = title
        self.selectionDisabled = selectionDisabled
    }
}
