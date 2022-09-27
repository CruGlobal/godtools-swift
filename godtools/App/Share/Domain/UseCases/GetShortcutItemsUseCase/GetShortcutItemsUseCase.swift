//
//  GetShortcutItemsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GetShortcutItemsUseCase {
    
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let maxShortcutItems: Int = 4
    
    init(getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, resourcesRepository: ResourcesRepository) {
     
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getShortcutItems() -> [UIApplicationShortcutItem] {
        
        var shortcutItems: [UIApplicationShortcutItem] = Array()
        
        let primaryLanguageCode: String = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier ?? "en"
        let parallelLanguageCode: String? = getSettingsParallelLanguageUseCase.getParallelLanguage()?.localeIdentifier
        
        let favoritedTools: [ToolDomainModel] = getAllFavoritedToolsUseCase.getFavoritedTools()
        
        for favoritedTool in favoritedTools {
            
            guard shortcutItems.count < maxShortcutItems else {
                break
            }
            
            let shortcutItem = ToolShortcutItem.shortcutItem(
                resourcesRepository: resourcesRepository,
                tool: favoritedTool,
                primaryLanguageCode: primaryLanguageCode,
                parallelLanguageCode: parallelLanguageCode
            )
            
            shortcutItems.append(shortcutItem)
        }
        
        return shortcutItems
    }
}
