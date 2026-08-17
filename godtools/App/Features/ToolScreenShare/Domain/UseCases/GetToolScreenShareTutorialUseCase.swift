//
//  GetToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> [ToolScreenShareTutorialPageDomainModel] {
        
        let localeId: String = appLanguage

        let shareYourScreenTitleKey: String = LocalizableStringKeys.shareToolScreenTutorialShareYourScreenTitle.key
        let shareYourScreenMessageKey: String = LocalizableStringKeys.shareToolScreenTutorialShareYourScreenMessage.key
        let mirroredExperienceTitleKey: String = LocalizableStringKeys.shareToolScreenTutorialMirroredExperienceTitle.key
        let mirroredExperienceMessageKey: String = LocalizableStringKeys.shareToolScreenTutorialMirroredExperienceMessage.key
        let getStartedTitleKey: String = LocalizableStringKeys.shareToolScreenTutorialGetStartedTitle.key
        let getStartedMessageKey: String = LocalizableStringKeys.shareToolScreenTutorialGetStartedMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                shareYourScreenTitleKey,
                shareYourScreenMessageKey,
                mirroredExperienceTitleKey,
                mirroredExperienceMessageKey,
                getStartedTitleKey,
                getStartedMessageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let tutorialPages = [
            ToolScreenShareTutorialPageDomainModel(
                title: strings[shareYourScreenTitleKey] ?? "",
                message: strings[shareYourScreenMessageKey] ?? "",
                media: .image(name: "share_tool_tutorial_people")
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: strings[mirroredExperienceTitleKey] ?? "",
                message: strings[mirroredExperienceMessageKey] ?? "",
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_mirrored"))
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: strings[getStartedTitleKey] ?? "",
                message: strings[getStartedMessageKey] ?? "",
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_link"))
            )
        ]

        return tutorialPages
    }
}
