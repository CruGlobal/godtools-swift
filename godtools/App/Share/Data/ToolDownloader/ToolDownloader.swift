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
        
        let translationsAndArticlesRequest: AnyPublisher<Void, Never> =
        downloadToolTranslationsAndArticlesRequest(translations: translations)
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
        
        let requests: [AnyPublisher<Void, Never>] = attachmentsRequests + [translationsAndArticlesRequest]
        
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
    
    private func downloadToolTranslationsAndArticlesRequest(translations: [TranslationModel]) -> AnyPublisher<[Void], Never> {
        
        let requests = translations.map { (translation: TranslationModel) in
            self.translationsRepository.downloadAndCacheTranslationFiles(translation: translation)
                .catch({ (error: Error) in
                    return Just(TranslationFilesDataModel(files: [], translation: translation))
                        .eraseToAnyPublisher()
                })
                .flatMap({ (dataModel: TranslationFilesDataModel) -> AnyPublisher<Void, Never> in
                    
                    let resource: ResourceModel? = dataModel.translation.resource
                    let resourceIsArticle: Bool = resource?.resourceTypeEnum == .article
                    
                    if resourceIsArticle, let languageCode = dataModel.translation.language?.code {
                        
                        return self.downloadArticlesPublisher(
                            translation: dataModel.translation,
                            languageCode: languageCode
                        )
                    }
                    
                    return Just(Void())
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func downloadArticlesPublisher(translation: TranslationModel, languageCode: String) -> AnyPublisher<Void, Never> {
        
        return translationsRepository
            .getTranslationManifestFromCache(translation: translation, manifestParserType: .manifestOnly, includeRelatedFiles: false)
            .flatMap({ (dataModel: TranslationManifestFileDataModel) -> AnyPublisher<ArticleAemRepositoryResult, Never> in
                                
                return self.articleManifestAemRepository
                    .downloadAndCacheManifestAemUrisPublisher(
                        manifest: dataModel.manifest,
                        languageCode: languageCode,
                        forceDownload: true
                    )
            })
            .flatMap({ (result: ArticleAemRepositoryResult) -> AnyPublisher<Void, Never> in
                
                return Just(Void())
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) in
                
                return Just(Void())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
