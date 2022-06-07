//
//  MockToolSettingsShareableItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockToolSettingsShareableItemViewModel: BaseToolSettingsShareableItemViewModel {
    
    init(imageName: String, title: String) {
        
        super.init()
        
        self.image = Image(imageName)
        self.title = title
    }
}
