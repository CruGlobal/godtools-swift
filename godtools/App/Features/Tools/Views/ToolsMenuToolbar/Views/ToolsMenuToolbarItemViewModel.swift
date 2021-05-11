//
//  ToolsMenuToolbarItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolsMenuToolbarItemViewModel: ToolsMenuToolbarItemViewModelType {
    
    let title: String
    let image: UIImage?
    
    required init(title: String, image: UIImage?) {
        
        self.title = title
        self.image = image
    }
}
