//
//  ToolsMenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolsMenuViewModelType {
            
    var navTitleFont: UIFont { get }
    
    func lessonsWillAppear() -> LessonsViewModel
    func favoritedToolsWillAppear() -> FavoritesContentViewModel
    func allToolsWillAppear() -> AllToolsContentViewModel
    func toolbarWillAppear() -> ToolsMenuToolbarViewModel
    func menuTapped()
    func languageTapped()
}
