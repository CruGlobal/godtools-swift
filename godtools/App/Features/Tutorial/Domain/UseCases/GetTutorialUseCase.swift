//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetTutorialUseCase: Sendable {
    
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

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                LocalizableStringKeys.tutorialLessonTitle.key,
                LocalizableStringKeys.tutorialLessonMessage.key,
                LocalizableStringKeys.tutorialToolTitle.key,
                LocalizableStringKeys.tutorialToolMessage.key,
                LocalizableStringKeys.tutorialToolTipTitle.key,
                LocalizableStringKeys.tutorialToolTipMessage.key,
                LocalizableStringKeys.tutorialScreenShareTitle.key,
                LocalizableStringKeys.tutorialScreenShareMessage.key,
                LocalizableStringKeys.tutorialFindTutorialTitle.key
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        switch tutorialType {

        case .full:
            return [
                getLessonsPage(strings: strings),
                getToolsPage(strings: strings),
                getToolTipsPage(strings: strings),
                getScreenSharePage(strings: strings),
                getFindThisPage(strings: strings)
            ]

        case .noTutorial:
            return []

        case .partial:
            return [
                getLessonsPage(strings: strings),
                getToolsPage(strings: strings),
                getScreenSharePage(strings: strings),
                getFindThisPage(strings: strings)
            ]
        }
    }

    private func getLessonsPage(strings: [String: String]) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: strings[LocalizableStringKeys.tutorialLessonTitle.key] ?? "",
            message: strings[LocalizableStringKeys.tutorialLessonMessage.key] ?? "",
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialLessons.fileName),
            imageName: nil
        )
    }

    private func getToolsPage(strings: [String: String]) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: strings[LocalizableStringKeys.tutorialToolTitle.key] ?? "",
            message: strings[LocalizableStringKeys.tutorialToolMessage.key] ?? "",
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialTool.rawValue
        )
    }
    private func getToolTipsPage(strings: [String: String]) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: strings[LocalizableStringKeys.tutorialToolTipTitle.key] ?? "",
            message: strings[LocalizableStringKeys.tutorialToolTipMessage.key] ?? "",
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialToolTip.fileName),
            imageName: nil
        )
    }

    private func getScreenSharePage(strings: [String: String]) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: strings[LocalizableStringKeys.tutorialScreenShareTitle.key] ?? "",
            message: strings[LocalizableStringKeys.tutorialScreenShareMessage.key] ?? "",
            videoId: nil,
            animatedResource: .mainBundleJsonFile(filename: LottieJson.tutorialScreenShare.fileName),
            imageName: nil
        )
    }

    private func getFindThisPage(strings: [String: String]) -> TutorialPageDomainModel {
        return TutorialPageDomainModel(
            title: strings[LocalizableStringKeys.tutorialFindTutorialTitle.key] ?? "",
            message: "",
            videoId: nil,
            animatedResource: nil,
            imageName: ImageCatalog.tutorialFindThis.name
        )
    }
}
