//
//  ToolTrainingTipsOnboardingViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolTrainingTipsOnboardingViewsCache: Sendable {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private func getNumberOfViewsKey(toolId: String, toolName: String) -> String {
                
        return "ToolTrainingTipsOnboardingViewsService." + toolName + "_" + toolId
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, toolName: String) async -> Int {

        let numberOfViews: Int? = await userDefaultsCache.getInt(key: getNumberOfViewsKey(toolId: toolId, toolName: toolName))

        return numberOfViews ?? 0
    }

    func storeToolTrainingTipViewed(toolId: String, toolName: String) async {

        let numberOfViews: Int = await getNumberOfToolTrainingTipViews(toolId: toolId, toolName: toolName)

        if numberOfViews < Int.max {

            let newNumberOfViews: Int = numberOfViews + 1

            await userDefaultsCache.storeInt(
                value: newNumberOfViews,
                forKey: getNumberOfViewsKey(toolId: toolId, toolName: toolName)
            )

            await userDefaultsCache.commitChanges()
        }
    }
}
