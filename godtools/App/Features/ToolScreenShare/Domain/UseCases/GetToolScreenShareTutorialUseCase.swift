//
//  GetToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> [ToolScreenShareTutorialPageDomainModel] {
        
        let localeId: String = appLanguage
        
        let tutorialPages = [
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialShareYourScreenTitle.key),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialShareYourScreenMessage.key),
                media: .image(name: "share_tool_tutorial_people")
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialMirroredExperienceTitle.key),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialMirroredExperienceMessage.key),
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_mirrored"))
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialGetStartedTitle.key),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolScreenTutorialGetStartedMessage.key),
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_link"))
            )
        ]
        
        return tutorialPages
    }
}
