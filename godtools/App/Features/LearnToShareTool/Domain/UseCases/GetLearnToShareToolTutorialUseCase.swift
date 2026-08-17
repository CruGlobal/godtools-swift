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

        let learnToShareTitleKey: String = LocalizableStringKeys.learnToShareToolLearnToShareTitle.key
        let learnToShareMessageKey: String = LocalizableStringKeys.learnToShareToolLearnToShareMessage.key
        let tipsLightTheWayTitleKey: String = LocalizableStringKeys.learnToShareToolTipsLightTheWayTitle.key
        let tipsLightTheWayMessageKey: String = LocalizableStringKeys.learnToShareToolTipsLightTheWayMessage.key
        let lightUpTheTipsTitleKey: String = LocalizableStringKeys.learnToShareToolLightUpTheTipsTitle.key
        let lightUpTheTipsMessageKey: String = LocalizableStringKeys.learnToShareToolLightUpTheTipsMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                learnToShareTitleKey,
                learnToShareMessageKey,
                tipsLightTheWayTitleKey,
                tipsLightTheWayMessageKey,
                lightUpTheTipsTitleKey,
                lightUpTheTipsMessageKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let items = [
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "learn_to_share_tool_with_anyone",
                title: strings[learnToShareTitleKey] ?? "",
                message: strings[learnToShareMessageKey] ?? ""
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_callout",
                title: strings[tipsLightTheWayTitleKey] ?? "",
                message: strings[tipsLightTheWayMessageKey] ?? ""
            ),
            LearnToShareToolItemDomainModel(
                imageName: nil,
                animationName: "training_tip_tips",
                title: strings[lightUpTheTipsTitleKey] ?? "",
                message: strings[lightUpTheTipsMessageKey] ?? ""
            )
        ]

        return items
    }
}
