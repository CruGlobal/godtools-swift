//
//  ToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared
import RequestOperation

class ToolDownloader {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let attachmentsRepository: AttachmentsRepository
    private let articleManifestAemRepository: ArticleManifestAemRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, attachmentsRepository: AttachmentsRepository, articleManifestAemRepository: ArticleManifestAemRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.attachmentsRepository = attachmentsRepository
        self.articleManifestAemRepository = articleManifestAemRepository
    }
    
    @MainActor func downloadToolsPublisher(tools: [DownloadToolDataModel], requestPriority: RequestPriority) -> AnyPublisher<ToolDownloaderDataModel, Error> {
            
        var nonArticleTranslations: [TranslationDataModel] = Array()
        var articleTranslations: [TranslationDataModel] = Array()
        var allTranslations: [TranslationDataModel] = Array()
        var attachments: [AttachmentDataModel] = Array()
        
        for tool in tools {
            
            let isArticle: Bool
            
            if let resource = resourcesRepository.persistence.getDataModelNonThrowing(id: tool.toolId) {
                
                if let resourceBanner = attachmentsRepository.cache.getAttachment(id: resource.attrBanner) {
                    attachments.append(resourceBanner)
                }
                
                if let resourceBannerAbout = attachmentsRepository.cache.getAttachment(id: resource.attrBannerAbout) {
                    attachments.append(resourceBannerAbout)
                }
                
                if let resourceAboutBannerAnimation = attachmentsRepository.cache.getAttachment(id: resource.attrAboutBannerAnimation) {
                    attachments.append(resourceAboutBannerAnimation)
                }
                
                isArticle = resource.resourceTypeEnum == .article
            }
            else {
                
                isArticle = false
            }
            
            for language in tool.languages {
                
                guard let translation = translationsRepository.cache.getLatestTranslation(resourceId: tool.toolId, languageCode: language) else {
                    continue
                }
                
                allTranslations.append(translation)
                
                if !isArticle {
                    nonArticleTranslations.append(translation)
                }
                else {
                    articleTranslations.append(translation)
                }
            }
        }
        
        let nonArticleTranslationDownloads: [AnyPublisher<Void, Error>] = getDownloadToolTranslationsPublishers(translations: nonArticleTranslations, requestPriority: requestPriority)
        let attachmentsDownloads: [AnyPublisher<Void, Error>] = getDownloadAttachmentsPublishers(attachments: attachments, requestPriority: requestPriority)
        let articleTranslationDownloads: [AnyPublisher<Void, Error>] = getDownloadArticlesPublishers(translations: articleTranslations, requestPriority: requestPriority)
        
        let allRequests: [AnyPublisher<Void, Error>] = nonArticleTranslationDownloads + attachmentsDownloads + articleTranslationDownloads
        
        var downloadCount: Int = 0
        
        return Publishers.MergeMany(allRequests)
            .map { (void: Void) in
                
                downloadCount += 1
                
                let numberOfRequests: Int = allRequests.count
                let progress: Double
                
                if downloadCount >= numberOfRequests {
                    progress = 1
                }
                else {
                    progress = Double(downloadCount) / Double(numberOfRequests)
                }
                                     
                return ToolDownloaderDataModel(
                    attachments: attachments,
                    progress: progress,
                    translations: allTranslations
                )
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor private func getDownloadToolTranslationsPublishers(translations: [TranslationDataModel], requestPriority: RequestPriority) -> [AnyPublisher<Void, Error>] {
            
        let downloadTranslationsRequests: [AnyPublisher<Void, Error>] = translations.map { (translation: TranslationDataModel) in
            self.translationsRepository.downloadAndCacheTranslationFiles(translation: translation, requestPriority: requestPriority)
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
        }
         
        return downloadTranslationsRequests
    }
    
    @MainActor private func getDownloadAttachmentsPublishers(attachments: [AttachmentDataModel], requestPriority: RequestPriority) -> [AnyPublisher<Void, Error>] {
        
        let downloadAttachmentsRequests: [AnyPublisher<Void, Error>] = attachments
            .map { (attachment: AttachmentDataModel) in
                self.attachmentsRepository.downloadAndCacheAttachmentDataIfNeededPublisher(attachment: attachment, requestPriority: requestPriority)
                    .map { _ in
                        return Void()
                    }
                    .eraseToAnyPublisher()
            }
        
        return downloadAttachmentsRequests
    }
    
    @MainActor private func getDownloadArticlesPublishers(translations: [TranslationDataModel], requestPriority: RequestPriority) -> [AnyPublisher<Void, Error>] {
        
        let downloadArticlesRequests: [AnyPublisher<Void, Error>] = translations.compactMap { (translation: TranslationDataModel) in
            
            guard let languageCode = translation.languageDataModel?.code else {
                return nil
            }
            
            return self.translationsRepository.getTranslationManifestFromCacheElseRemote(
                translation: translation,
                manifestParserType: .manifestOnly,
                requestPriority: requestPriority,
                includeRelatedFiles: true,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
            )
            .flatMap { (translationManifestDataModel: TranslationManifestFileDataModel) in
                
                return self.articleManifestAemRepository.downloadAndCacheManifestAemUrisPublisher(
                    manifest: translationManifestDataModel.manifest,
                    translationId: translation.id,
                    languageCode: languageCode,
                    downloadCachePolicy: .ignoreCache,
                    requestPriority: requestPriority
                )
                .map { (result: ArticleAemRepositoryResult) in
                    Void()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        
        return downloadArticlesRequests
    }
}
