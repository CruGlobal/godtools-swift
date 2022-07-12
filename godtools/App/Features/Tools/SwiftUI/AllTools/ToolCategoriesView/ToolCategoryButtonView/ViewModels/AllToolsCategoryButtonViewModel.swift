//
//  AllToolsCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllToolsCategoryButtonViewModel: BaseToolCategoryButtonViewModel {
    
    init(selectedAttrCategory: String?) {
        
        let buttonState: ToolCategoryButtonState = selectedAttrCategory == nil ? .selected : .notSelected
        
        super.init(categoryText: "All Tools", buttonState: buttonState)
    }
    
    override func updateStateWithSelectedCategory(_ selectedAttrCategory: String?) {
        
        let buttonState: ToolCategoryButtonState = selectedAttrCategory == nil ? .selected : .greyedOut
        
        setButtonState(buttonState)
    }
}
