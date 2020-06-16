//
//  ToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsViewModelType {
    
    var resourcesService: ResourcesService { get }
    var favoritedResourcesCache: RealmFavoritedResourcesCache { get }
    var languageSettingsCache: LanguageSettingsCacheType { get }
    var tools: ObservableValue<[ResourceModel]> { get }
    var toolListIsEditable: Bool { get }
    
    func toolTapped(resource: ResourceModel)
    func aboutToolTapped(resource: ResourceModel)
    func openToolTapped(resource: ResourceModel)
    func favoriteToolTapped(resource: ResourceModel)
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath)
}

extension ToolsViewModelType {
    func reloadTools() {
        tools.accept(value: tools.value)
    }
}
