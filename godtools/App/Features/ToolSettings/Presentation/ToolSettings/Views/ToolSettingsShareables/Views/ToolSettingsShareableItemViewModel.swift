//
//  ToolSettingsShareableItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolSettingsShareableItemViewModel: BaseToolSettingsShareableItemViewModel {
    
    private let shareable: Shareable
    
    required init(shareable: Shareable) {
        
        self.shareable = shareable
        
        super.init()
                
        if let shareableImage = shareable as? ShareableImage {
            self.title = shareableImage.description_?.text ?? ""
        }
    }
}
