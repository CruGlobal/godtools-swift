//
//  ToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsViewModelType {
    
    var favoritedResourcesCache: RealmFavoritedResourcesCache { get }
    var tools: ObservableValue<[RealmResource]> { get }
    var toolListIsEditable: Bool { get }
    
    func toolTapped(resource: RealmResource)
    func aboutToolTapped(resource: RealmResource)
    func openToolTapped(resource: RealmResource)
    func favoriteToolTapped(resource: RealmResource)
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath)
}

extension ToolsViewModelType {
    func reloadTools() {
        tools.accept(value: tools.value)
    }
}
