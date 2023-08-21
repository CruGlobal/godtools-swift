//
//  GetLearnToShareToolItemsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLearnToShareToolItemsUseCase {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getItemsPublisher() -> AnyPublisher<[LearnToShareToolItemDomainModel], Never> {
        
        return Just(getItemsValue())
            .eraseToAnyPublisher()
    }
    
    private func getItemsValue() -> [LearnToShareToolItemDomainModel] {
        
        return [
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.learn_to_share.title"),
                message: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.learn_to_share.message")
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName:  "training_tip_callout",
                title: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.tips_light_the_way.title"),
                message: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.tips_light_the_way.message")
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_tips",
                title: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.light_up_the_tips.title"),
                message: localizationServices.stringForSystemElseEnglish(key: "learn_to_share_tool.light_up_the_tips.message")
            )
        ]
    }
}
