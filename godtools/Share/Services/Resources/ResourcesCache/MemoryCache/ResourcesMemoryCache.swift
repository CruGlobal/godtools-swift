//
//  ResourcesMemoryCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesMemoryCache: ResourcesCacheType {
    
    private var languagesDictionary: [String: LanguageModel] = Dictionary()
    private var resourcesDictionary: [String: ResourceModel] = Dictionary()
    private var translationsDictionary: [String: TranslationModel] = Dictionary()
    private var attachmentsDictionary: [String: AttachmentModel] = Dictionary()
    
    required init() {
        
    }
    
    func cacheResources(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, complete: @escaping ((_ error: ResourcesCacheError?) -> Void)) {
        
        DispatchQueue.global().async { [weak self] in
                   
            var languagesDictionary: [String: LanguageModel] = Dictionary()
            var resourcesDictionary: [String: ResourceModel] = Dictionary()
            var translationsDictionary: [String: TranslationModel] = Dictionary()
            var attachmentsDictionary: [String: AttachmentModel] = Dictionary()
            
            for language in languages {
                languagesDictionary[language.id] = language
            }
            
            for resource in resourcesPlusLatestTranslationsAndAttachments.resources {
                resourcesDictionary[resource.id] = resource
            }
            
            for translation in resourcesPlusLatestTranslationsAndAttachments.translations {
                translationsDictionary[translation.id] = translation
            }
            
            for attachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                attachmentsDictionary[attachment.id] = attachment
            }
            
            self?.languagesDictionary = languagesDictionary
            self?.resourcesDictionary = resourcesDictionary
            self?.translationsDictionary = translationsDictionary
            self?.attachmentsDictionary = attachmentsDictionary
            
            complete(nil)
        }
    }
    
    func getLanguages() -> [LanguageModel] {
        return Array(languagesDictionary.values)
    }
    
    func getResources() -> [ResourceModel] {
        return Array(resourcesDictionary.values)
    }
}
