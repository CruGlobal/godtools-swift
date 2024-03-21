//
//  ToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolDownloader {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let attachmentsRepository: AttachmentsRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, attachmentsRepository: AttachmentsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.attachmentsRepository = attachmentsRepository
    }
    
    func downloadToolsPublisher(tools: [DownloadToolDataModel]) -> AnyPublisher<ToolDownloaderDataModel, Never> {
        
        var translations: [TranslationModel] = Array()
        var attachments: [AttachmentModel] = Array()
        
        for tool in tools {
            
            if let resource = resourcesRepository.getResource(id: tool.toolId) {
                
                if let resourceBanner = attachmentsRepository.getAttachmentModel(id: resource.attrBanner) {
                    attachments.append(resourceBanner)
                }
                
                if let resourceBannerAbout = attachmentsRepository.getAttachmentModel(id: resource.attrBannerAbout) {
                    attachments.append(resourceBannerAbout)
                }
            }
            
            for language in tool.languages {
                if let translation = translationsRepository.getLatestTranslation(resourceId: tool.toolId, languageCode: language) {
                    translations.append(translation)
                }
            }
        }
        
        let translationsRequest: AnyPublisher<Void, Never> = translationsRepository
            .downloadAndCacheFilesForTranslationsIgnoringError(translations: translations)
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
        
        let attachmentsRequests: [AnyPublisher<Void, Never>] = attachments
            .map { (attachment: AttachmentModel) in
                self.attachmentsRepository.downloadAndCacheAttachmentIfNeeded(attachment: attachment)
                    .map { _ in
                        return Void()
                    }
                    .catch { (error: Error) in
                        return Just(Void())
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        
        let requests: [AnyPublisher<Void, Never>] = attachmentsRequests + [translationsRequest]
        
        var downloadCount: Double = 0
        
        return Publishers.MergeMany(requests)
            .map { (void: Void) in
                
                downloadCount += 1
                                
                return ToolDownloaderDataModel(
                    attachments: attachments,
                    progress: downloadCount / Double(requests.count),
                    translations: translations
                )
            }
            .eraseToAnyPublisher()
    }
}
