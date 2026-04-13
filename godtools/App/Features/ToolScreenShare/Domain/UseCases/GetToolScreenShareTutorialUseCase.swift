//
//  GetToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolScreenShareTutorialUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolScreenShareTutorialPageDomainModel], Never> {
        
        let localeId: String = appLanguage
        
        let tutorialPages = [
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.share_your_screen.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.share_your_screen.message"),
                media: .image(name: "share_tool_tutorial_people")
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.mirrored_experience.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.mirrored_experience.message"),
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_mirrored"))
            ),
            ToolScreenShareTutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.get_started.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_screen_tutorial.get_started.message"),
                media: .animation(animatedResource: .mainBundleJsonFile(filename: "share_tool_tutorial_link"))
            )
        ]
        
        return Just(tutorialPages)
            .eraseToAnyPublisher()
    }
}
