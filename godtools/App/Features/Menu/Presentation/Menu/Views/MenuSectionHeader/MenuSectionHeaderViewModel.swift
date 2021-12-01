//
//  MenuSectionHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuSectionHeaderViewModel: MenuSectionHeaderViewModelType {
    
    let headerTitle: String
    
    required init(headerTitle: String) {
        
        self.headerTitle = headerTitle.uppercased()
    }
}
