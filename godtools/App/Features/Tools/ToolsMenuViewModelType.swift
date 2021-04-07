//
//  ToolsMenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsMenuViewModelType {
            
    func toolbarWillAppear() -> ToolsMenuToolbarViewModelType
    func menuTapped()
    func languageTapped()
}
