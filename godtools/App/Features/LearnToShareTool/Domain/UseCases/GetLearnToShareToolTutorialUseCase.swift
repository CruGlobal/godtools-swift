//
//  GetLearnToShareToolTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLearnToShareToolTutorialUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LearnToShareToolItemDomainModel], Never> {
        
        let localeId: String = appLanguage
        
        let items = [
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.learn_to_share.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.learn_to_share.message")
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_callout",
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.tips_light_the_way.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.tips_light_the_way.message")
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_tips",
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.light_up_the_tips.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "learn_to_share_tool.light_up_the_tips.message")
            )
        ]
        
        return Just(items)
            .eraseToAnyPublisher()
    }
}
