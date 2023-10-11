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
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getDetailsPublisher(tool: ToolDomainModel, translateInToolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        let defaultTool = ToolDetailsDomainModel(
            aboutDescription: "",
            bibleReferences: "",
            conversationStarters: "",
            languagesAvailable: "",
            name: "",
            numberOfViews: "",
            versions: [],
            versionsDescription: ""
        )
        
        guard let toolDataModel = resourcesRepository.getResource(id: tool.dataModelId),
              let toolLanguageDataModel = languagesRepository.getLanguage(code: translateInToolLanguageCode) else {
            
            return Just(defaultTool)
                .eraseToAnyPublisher()
        }
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: tool.dataModelId, languageCode: translateInToolLanguageCode) else {
            
            return Just(defaultTool)
                .eraseToAnyPublisher()
        }
        
        let numberOfViewsString: String = String(
            format: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInToolLanguageCode, key: "total_views").capitalized,
            locale: Locale(identifier: translateInToolLanguageCode),
            toolDataModel.totalViews
        )
        
        let languagesDataModels: [LanguageModel] = languagesRepository.getLanguages(ids: toolDataModel.languageIds)
        
        let languages: [ToolDetailsToolLanguageDomainModel] = languagesDataModels.compactMap { (languageDataModel: LanguageModel) in
            
            guard let languageDisplayName = self.localeLanguageName.getDisplayName(forLanguageCode: languageDataModel.code, translatedInLanguageCode: translateInToolLanguageCode) else {
                return nil
            }
            
            return ToolDetailsToolLanguageDomainModel(
                languageNameTranslatedInToolLanguage: languageDisplayName
            )
        }
        
        let languagesAvailable: String = languages.map({$0.languageNameTranslatedInToolLanguage}).sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        let resourceVariants: [ResourceModel]
        
        if let metatoolId = toolDataModel.metatoolId, !metatoolId.isEmpty {
            resourceVariants = resourcesRepository.getResourceVariants(resourceId: metatoolId)
        }
        else {
            resourceVariants = []
        }
        
        let localizedTotalLanguages: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInToolLanguageCode, key: "total_languages")
        let toolLanguageName: String? = localeLanguageName.getDisplayName(forLanguageCode: translateInToolLanguageCode, translatedInLanguageCode: translateInToolLanguageCode)
        
        let versions: [ToolVersionDomainModel] = resourceVariants.compactMap { (variantDataModel: ResourceModel) in
            
            guard let translation = self.translationsRepository.getLatestTranslation(resourceId: variantDataModel.id, languageCode: translateInToolLanguageCode) else {
                return nil
            }
            
            let numberOfLanguagesString: String = String(
                format: localizedTotalLanguages,
                locale: Locale(identifier: translateInToolLanguageCode),
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
            languagesAvailable: languagesAvailable,
            name: translation.translatedName,
            numberOfViews: numberOfViewsString,
            versions: versions,
            versionsDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInToolLanguageCode, key: "toolDetails.versions.message")
        )
        
        return Just(toolDetails)
            .eraseToAnyPublisher()
    }
}
