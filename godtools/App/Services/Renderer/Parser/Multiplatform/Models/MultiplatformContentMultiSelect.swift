//
//  MultiplatformContentMultiSelect.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentMultiSelect {
    
    private let multiSelect: Multiselect
    
    required init(multiSelect: Multiselect) {
        
        self.multiSelect = multiSelect
    }
    
    var numberOfColumns: Int32 {
        return multiSelect.columns
    }
}
