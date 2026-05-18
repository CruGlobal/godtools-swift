//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetTutorialUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTutorialType: GetTutorialType
        
    init(localizationServices: LocalizationServicesInterface, getTutorialType: GetTutorialType) {
        
        self.localizationServices = localizationServices
        self.getTutorialType = getTutorialType
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> TutorialDomainModel {
        
        return TutorialDomainModel(
            pages: getTutorialPages(
                tutorialType: getTutorialType.getType(appLanguage: appLanguage),
                appLanguage: appLanguage
            )
        )
    }
    
    private func getTutorialPages(tutorialType: TutorialTypeDomainModel, appLanguage: AppLanguageDomainModel) -> [TutorialPageDomainModel] {
        
        switch tutorialType {
        
        case .full:
            return [
                getLessonsPage(appLanguage: appLanguage),
                getToolsPage(appLanguage: appLanguage),
                getToolTipsPage(appLanguage: appLanguage),
                getScreenSharePage(appLanguage: appLanguage),
                getFindThisPage(appLanguage: appLanguage)
            ]
        
        case .noTutorial:
            return []
        
        case .partial:
            return [
                getLessonsPage(appLanguage: appLanguage),
                getToolsPage(appLanguage: appLanguage),
                getScreenSharePage(appLanguage: appLanguage),
                getFindThisPage(appLanguage: appLanguage)
            ]
        }
    }
    
    private func getLessonsPage(appLanguage: AppLanguageDomainModel) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialLessonTitle.key),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialLessonMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: "tutorial_lessons"),
            imageName: nil
        )
    }
    
    private func getToolsPage(appLanguage: AppLanguageDomainModel) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTitle.key),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolMessage.key),
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialTool.rawValue
        )
    }
    private func getToolTipsPage(appLanguage: AppLanguageDomainModel) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTipTitle.key),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTipMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: "tutorial_tooltip"),
            imageName: nil
        )
    }
    
    private func getScreenSharePage(appLanguage: AppLanguageDomainModel) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialScreenShareTitle.key),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialScreenShareMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: "tutorial_screenshare"),
            imageName: nil
        )
    }
    
    private func getFindThisPage(appLanguage: AppLanguageDomainModel) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialFindTutorialTitle.key),
            message: "",
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialInMenuEnglish.name
        )
    }
}
