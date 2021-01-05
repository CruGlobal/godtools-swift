//
//  InMemoryLearnToShareToolItems.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class InMemoryLearnToShareToolItems: LearnToShareToolItemsProviderType {
    
    let learnToShareToolItems: ObservableValue<[LearnToShareToolItem]>
    
    required init(localization: LocalizationServices) {
        
        let items = [
            LearnToShareToolItem(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: localization.stringForMainBundle(key: "learn_to_share_tool.learn_to_share.title"),
                message: localization.stringForMainBundle(key: "learn_to_share_tool.learn_to_share.message")
            ),
            LearnToShareToolItem(
                imageName: nil,
                animationName:  "training_tip_callout",
                title: localization.stringForMainBundle(key: "learn_to_share_tool.tips_light_the_way.title"),
                message: localization.stringForMainBundle(key: "learn_to_share_tool.tips_light_the_way.message")
            ),
            LearnToShareToolItem(
                imageName: nil,
                animationName: "training_tip_tips",
                title: localization.stringForMainBundle(key: "learn_to_share_tool.light_up_the_tips.title"),
                message: localization.stringForMainBundle(key: "learn_to_share_tool.light_up_the_tips.message")
            )
        ]
        
        learnToShareToolItems = ObservableValue(value: items)
    }
}
