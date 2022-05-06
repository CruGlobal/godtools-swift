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
    
    func lessonsWillAppear() -> LessonsListViewModelType
    func favoritedToolsWillAppear() -> FavoritedToolsViewModelType
    func allToolsWillAppear() -> AllToolsViewModelType
    func toolbarWillAppear() -> ToolsMenuToolbarViewModelType
    func menuTapped()
    func languageTapped()
    func didViewLessonsList()
    func didViewFavoritedToolsList()
    func didViewAllToolsList()
}
