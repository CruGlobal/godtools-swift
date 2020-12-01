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
    
    required init() {
        
        let items = [
            LearnToShareToolItem(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: "Learn to share this tool with anyone.",
                message: "This tool helps guide a conversation about how someone begins a relationship with God.  Practice sharing the content using the tips provided, so you feel ready to talk to someone else."
            ),
            LearnToShareToolItem(
                imageName: "training_tip_callout",
                animationName: nil,
                title: "Tips to light the way",
                message: "On select screens of this training, you'll see one of the icons above. Press the icon to reveal a tip that will help you talk about the content of the screen. If a screen has no icon, then the tip is to just read through the content and discuss as needed."
            ),
            LearnToShareToolItem(
                imageName: "training_tip_tips",
                animationName: nil,
                title: "Light up the tips",
                message: "When a tip lights up, you’ve completed that piece of training. Practice using as many tips as you need to feel confident explaining the tool."
            )
        ]
        
        learnToShareToolItems = ObservableValue(value: items)
    }
}
