//
//  ToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsViewModelType {
    
    var dataDownloader: InitialDataDownloader { get }
    var languageSettingsService: LanguageSettingsService { get }
    var localizationServices: LocalizationServices { get }
    var favoritedResourcesCache: FavoritedResourcesCache { get }
    var fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel { get }
    var deviceAttachmentBanners: DeviceAttachmentBanners { get }
    var tools: ObservableValue<[ResourceModel]> { get }
    var toolRefreshed: SignalValue<IndexPath> { get }
    var toolsAdded: ObservableValue<[IndexPath]> { get }
    var toolsRemoved: ObservableValue<[IndexPath]> { get }
    var toolListIsEditable: Bool { get }
    var toolListIsEditing: ObservableValue<Bool> { get }
    
    func toolTapped(resource: ResourceModel)
    func aboutToolTapped(resource: ResourceModel)
    func openToolTapped(resource: ResourceModel)
    func favoriteToolTapped(resource: ResourceModel)
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath)
}

extension ToolsViewModelType {
    
    func reloadTool(resourceId: String) {
        for index in 0 ..< tools.value.count {
            if tools.value[index].id == resourceId {
                let indexPath: IndexPath = IndexPath(row: index, section: 0)
                toolRefreshed.accept(value: indexPath)
                return
            }
        }
    }
    
    func reloadAllTools() {
        tools.accept(value: tools.value)
    }
    
    func addTool(tool: ResourceModel) {
        
        var updatedToolsList: [ResourceModel] = tools.value
        updatedToolsList.insert(tool, at: 0)
        
        let addedIndexPaths: [IndexPath] = [IndexPath(row: 0, section: 0)]
        
        tools.setValue(value: updatedToolsList)
        toolsAdded.accept(value: addedIndexPaths)
    }

    func removeTools(toolIdsToRemove: [String]) {
        let toolsToRemove: [ResourceModel] = tools.value.filter({toolIdsToRemove.contains($0.id)})
        removeTools(toolsToRemove: toolsToRemove)
    }
    
    func removeTools(toolsToRemove: [ResourceModel]) {
        
        guard !tools.value.isEmpty && !toolsToRemove.isEmpty else {
            return
        }
        
        var updatedToolsList: [ResourceModel] = tools.value
        var removedIndexPaths: [IndexPath] = Array()
        
        for toolToRemove in toolsToRemove {
            if let index = updatedToolsList.firstIndex(of: toolToRemove) {
                removedIndexPaths.append(IndexPath(row: index, section: 0))
                updatedToolsList.remove(at: index)
            }
        }
        
        tools.setValue(value: updatedToolsList)
        toolsRemoved.accept(value: removedIndexPaths)
    }
}
