//
//  ToolDownloaderGetDataToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class ToolDownloaderGetDataToDownload {
    
    private let resourcesRepository: ResourcesRepository
    private let attachmentsRepository: AttachmentsRepository
    private let translationsRepository: TranslationsRepository
    
    init(resourcesRepository: ResourcesRepository, attachmentsRepository: AttachmentsRepository, translationsRepository: TranslationsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.attachmentsRepository = attachmentsRepository
        self.translationsRepository = translationsRepository
    }
    
    func getData(tools: [DownloadToolData]) throws -> ToolDownloaderDataToDownload {
        
        var nonArticleTranslations: [TranslationDataModel] = Array()
        var articleTranslations: [TranslationDataModel] = Array()
        var allTranslations: [TranslationDataModel] = Array()
        var attachments: [AttachmentDataModel] = Array()
        
        for tool in tools {
            
            let isArticle: Bool
            
            if let resource = try resourcesRepository.getResource(id: tool.toolId) {
                
                isArticle = resource.resourceTypeEnum == .article
                
                if let resourceBanner = try attachmentsRepository.getAttachment(id: resource.attrBanner) {
                    attachments.append(resourceBanner)
                }
                
                if let resourceBannerAbout = try attachmentsRepository.getAttachment(id: resource.attrBannerAbout) {
                    attachments.append(resourceBannerAbout)
                }
                
                if let resourceAboutBannerAnimation = try attachmentsRepository.getAttachment(id: resource.attrAboutBannerAnimation) {
                    attachments.append(resourceAboutBannerAnimation)
                }
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
        
        return ToolDownloaderDataToDownload(
            nonArticleTranslations: nonArticleTranslations,
            articleTranslations: articleTranslations,
            attachments: attachments
        )
    }
}
