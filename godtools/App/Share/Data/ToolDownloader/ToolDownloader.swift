//
//  ToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

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
    
    func downloadToolsPublisher(tools: [DownloadToolDataModel]) -> AnyPublisher<ToolDownloaderDataModel, Error> {
        
        var nonArticleTranslations: [TranslationModel] = Array()
        var articleTranslations: [TranslationModel] = Array()
        var allTranslations: [TranslationModel] = Array()
        var attachments: [AttachmentModel] = Array()
        
        for tool in tools {
            
            let isArticle: Bool
            
            if let resource = resourcesRepository.getResource(id: tool.toolId) {
                
                if let resourceBanner = attachmentsRepository.getAttachmentModel(id: resource.attrBanner) {
                    attachments.append(resourceBanner)
                }
                
                if let resourceBannerAbout = attachmentsRepository.getAttachmentModel(id: resource.attrBannerAbout) {
                    attachments.append(resourceBannerAbout)
                }
                
                if let resourceAboutBannerAnimation = attachmentsRepository.getAttachmentModel(id: resource.attrAboutBannerAnimation) {
                    attachments.append(resourceAboutBannerAnimation)
                }
                
                isArticle = resource.resourceTypeEnum == .article
            }
            else {
                
                isArticle = false
            }
            
            for language in tool.languages {
                
                guard let translation = translationsRepository.getLatestTranslation(resourceId: tool.toolId, languageCode: language) else {
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
        
        let nonArticleTranslationDownloads: [AnyPublisher<Void, Error>] = getDownloadToolTranslationsPublishers(translations: nonArticleTranslations)
        let attachmentsDownloads: [AnyPublisher<Void, Error>] = getDownloadAttachmentsPublishers(attachments: attachments)
        let articleTranslationDownloads: [AnyPublisher<Void, Error>] = getDownloadArticlesPublishers(translations: articleTranslations)
        
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
    
    private func getDownloadToolTranslationsPublishers(translations: [TranslationModel]) -> [AnyPublisher<Void, Error>] {
        
        let downloadTranslationsRequests: [AnyPublisher<Void, Error>] = translations.map { (translation: TranslationModel) in
            self.translationsRepository.downloadAndCacheTranslationFiles(translation: translation)
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
        }
         
        return downloadTranslationsRequests
    }
    
    private func getDownloadAttachmentsPublishers(attachments: [AttachmentModel]) -> [AnyPublisher<Void, Error>] {
        
        let downloadAttachmentsRequests: [AnyPublisher<Void, Error>] = attachments
            .map { (attachment: AttachmentModel) in
                self.attachmentsRepository.downloadAndCacheAttachmentIfNeeded(attachment: attachment)
                    .map { _ in
                        return Void()
                    }
                    .eraseToAnyPublisher()
            }
        
        return downloadAttachmentsRequests
    }
    
    private func getDownloadArticlesPublishers(translations: [TranslationModel]) -> [AnyPublisher<Void, Error>] {
        
        let downloadArticlesRequests: [AnyPublisher<Void, Error>] = translations.compactMap { (translation: TranslationModel) in
            
            guard let languageCode = translation.language?.localeId else {
                return nil
            }
            
            return self.translationsRepository.getTranslationManifestFromCacheElseRemote(
                translation: translation,
                manifestParserType: .manifestOnly,
                includeRelatedFiles: false,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
            )
            .map { (translationManifestDataModel: TranslationManifestFileDataModel) in
                
                return self.articleManifestAemRepository.downloadAndCacheManifestAemUrisPublisher(
                    manifest: translationManifestDataModel.manifest,
                    languageCode: languageCode,
                    forceDownload: true
                )
            }
            .map { _ in
                return Void()
            }
            .eraseToAnyPublisher()
        }
        
        return downloadArticlesRequests
    }
}
