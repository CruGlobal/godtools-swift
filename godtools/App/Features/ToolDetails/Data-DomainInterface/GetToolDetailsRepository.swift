//
//  GetToolDetailsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsRepository: GetToolDetailsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let getInterfaceStringForLanguageRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    private let localeLanguageName: LocaleLanguageName
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, getInterfaceStringForLanguageRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface, localeLanguageName: LocaleLanguageName) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.getInterfaceStringForLanguageRepositoryInterface = getInterfaceStringForLanguageRepositoryInterface
        self.localeLanguageName = localeLanguageName
    }
    
    func getToolDetailsPublisher(tool: ToolDomainModel, inToolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        let defaultTool = ToolDetailsDomainModel(
            aboutDescription: "",
            bibleReferences: "",
            conversationStarters: "",
            languages: [],
            name: "",
            numberOfViews: "",
            versions: [],
            versionsDescription: ""
        )
        
        guard let toolDataModel = resourcesRepository.getResource(id: tool.dataModelId),
              let toolLanguageDataModel = languagesRepository.getLanguage(code: inToolLanguageCode) else {
            
            return Just(defaultTool)
                .eraseToAnyPublisher()
        }
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: tool.dataModelId, languageCode: inToolLanguageCode) else {
            
            return Just(defaultTool)
                .eraseToAnyPublisher()
        }
        
        let numberOfViewsString: String = String(
            format: getInterfaceStringForLanguageRepositoryInterface.getString(languageCode: inToolLanguageCode, stringId: "total_views").capitalized,
            locale: Locale(identifier: inToolLanguageCode),
            toolDataModel.totalViews
        )
        
        let languagesDataModels: [LanguageModel] = languagesRepository.getLanguages(ids: toolDataModel.languageIds)
        
        let languages: [ToolDetailsToolLanguageDomainModel] = languagesDataModels.compactMap { (languageDataModel: LanguageModel) in
            
            guard let languageDisplayName = self.localeLanguageName.getDisplayName(forLanguageCode: languageDataModel.code, translatedInLanguageCode: inToolLanguageCode) else {
                return nil
            }
            
            return ToolDetailsToolLanguageDomainModel(
                languageNameTranslatedInToolLanguage: languageDisplayName
            )
        }
        
        let resourceVariants: [ResourceModel]
        
        if let metatoolId = toolDataModel.metatoolId, !metatoolId.isEmpty {
            resourceVariants = resourcesRepository.getResourceVariants(resourceId: metatoolId)
        }
        else {
            resourceVariants = []
        }
        
        let localizedTotalLanguages: String = getInterfaceStringForLanguageRepositoryInterface.getString(languageCode: inToolLanguageCode, stringId: "total_languages")
        let toolLanguageName: String? = localeLanguageName.getDisplayName(forLanguageCode: inToolLanguageCode, translatedInLanguageCode: inToolLanguageCode)
        
        let versions: [ToolVersionDomainModel] = resourceVariants.compactMap { (variantDataModel: ResourceModel) in
            
            guard let translation = self.translationsRepository.getLatestTranslation(resourceId: variantDataModel.id, languageCode: inToolLanguageCode) else {
                return nil
            }
            
            let numberOfLanguagesString: String = String(
                format: localizedTotalLanguages,
                locale: Locale(identifier: inToolLanguageCode),
                variantDataModel.languageIds.count
            )
            
            return ToolVersionDomainModel(
                bannerImageId: variantDataModel.attrBanner,
                dataModelId: variantDataModel.id,
                description: translation.translatedTagline,
                name: translation.translatedName,
                numberOfLanguages: numberOfLanguagesString,
                toolLanguageName: toolLanguageName ?? "",
                toolLanguageNameIsSupported: variantDataModel.languageIds.contains(toolLanguageDataModel.id)
            )
        }
        
        let toolDetails = ToolDetailsDomainModel(
            aboutDescription: translation.translatedDescription,
            bibleReferences: translation.toolDetailsBibleReferences,
            conversationStarters: translation.toolDetailsConversationStarters,
            languages: languages,
            name: translation.translatedName,
            numberOfViews: numberOfViewsString,
            versions: versions,
            versionsDescription: getInterfaceStringForLanguageRepositoryInterface.getString(languageCode: inToolLanguageCode, stringId: "toolDetails.versions.message")
        )
        
        return Just(toolDetails)
            .eraseToAnyPublisher()
    }
}