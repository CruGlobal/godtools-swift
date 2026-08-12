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
    
    func execute(appLanguage: AppLanguageDomainModel) async -> TutorialDomainModel {
        
        return TutorialDomainModel(
            pages: await getTutorialPages(
                tutorialType: getTutorialType.getType(appLanguage: appLanguage),
                appLanguage: appLanguage
            )
        )
    }
    
    private func getTutorialPages(tutorialType: TutorialTypeDomainModel, appLanguage: AppLanguageDomainModel) async -> [TutorialPageDomainModel] {
        
        switch tutorialType {
        
        case .full:
            return [
                await getLessonsPage(appLanguage: appLanguage),
                await getToolsPage(appLanguage: appLanguage),
                await getToolTipsPage(appLanguage: appLanguage),
                await getScreenSharePage(appLanguage: appLanguage),
                await getFindThisPage(appLanguage: appLanguage)
            ]
        
        case .noTutorial:
            return []
        
        case .partial:
            return [
                await getLessonsPage(appLanguage: appLanguage),
                await getToolsPage(appLanguage: appLanguage),
                await getScreenSharePage(appLanguage: appLanguage),
                await getFindThisPage(appLanguage: appLanguage)
            ]
        }
    }
    
    private func getLessonsPage(appLanguage: AppLanguageDomainModel) async -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialLessonTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialLessonMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialLessons.fileName),
            imageName: nil
        )
    }
    
    private func getToolsPage(appLanguage: AppLanguageDomainModel) async -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolMessage.key),
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialTool.rawValue
        )
    }
    private func getToolTipsPage(appLanguage: AppLanguageDomainModel) async -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTipTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialToolTipMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialToolTip.fileName),
            imageName: nil
        )
    }
    
    private func getScreenSharePage(appLanguage: AppLanguageDomainModel) async -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialScreenShareTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialScreenShareMessage.key),
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialScreenShare.fileName),
            imageName: nil
        )
    }
    
    private func getFindThisPage(appLanguage: AppLanguageDomainModel) async -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tutorialFindTutorialTitle.key),
            message: "",
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialFindThis.name
        )
    }
}
