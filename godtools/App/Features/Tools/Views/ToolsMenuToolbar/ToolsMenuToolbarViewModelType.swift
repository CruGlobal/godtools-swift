//
//  ToolsMenuToolbarViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolsMenuToolbarViewModelType {
    
    var numberOfToolbarItems: ObservableValue<Int> { get }
    
    func toolbarItemWillAppear(index: Int) -> ToolsMenuToolbarItemViewModelType
}
