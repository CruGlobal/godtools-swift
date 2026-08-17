//
//  GetLearnToShareToolTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLearnToShareToolTutorialUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> [LearnToShareToolItemDomainModel] {
        
        let localeId: String = appLanguage
        
        let items = [
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLearnToShareTitle.key),
                message: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLearnToShareMessage.key)
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_callout",
                title: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolTipsLightTheWayTitle.key),
                message: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolTipsLightTheWayMessage.key)
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_tips",
                title: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLightUpTheTipsTitle.key),
                message: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: localeId, key: LocalizableStringKeys.learnToShareToolLightUpTheTipsMessage.key)
            )
        ]
        
        return items
    }
}
