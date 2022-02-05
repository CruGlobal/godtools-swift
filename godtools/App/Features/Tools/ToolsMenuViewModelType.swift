//
//  ToolsMenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsMenuViewModelType {
                   
    func lessonsWillAppear() -> LessonsListViewModelType
    func favoritedToolsWillAppear() -> FavoritedToolsViewModelType
    func allToolsWillAppear() -> AllToolsViewModelType
    func toolbarWillAppear() -> ToolsMenuToolbarViewModelType
    func menuTapped()
    func languageTapped()
    func didViewFavoritedToolsList()
    func didViewAllToolsList()
}
