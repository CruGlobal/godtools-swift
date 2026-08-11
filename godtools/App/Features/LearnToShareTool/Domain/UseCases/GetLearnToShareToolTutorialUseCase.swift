//
//  GetLearnToShareToolTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLearnToShareToolTutorialUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> [LearnToShareToolItemDomainModel] {
        
        let localeId: String = appLanguage
        
        let items = [
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLearnToShareTitle.key),
                message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLearnToShareMessage.key)
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_callout",
                title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolTipsLightTheWayTitle.key),
                message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolTipsLightTheWayMessage.key)
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_tips",
                title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLightUpTheTipsTitle.key),
                message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLightUpTheTipsMessage.key)
            )
        ]
        
        return items
    }
}
