//
//  ToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class ToolDownloader {
    
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let attachmentsRepository: AttachmentsRepository
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let getToolDataToDownload: ToolDownloaderGetDataToDownload
    
    init(languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, attachmentsRepository: AttachmentsRepository, articleManifestAemRepository: ArticleManifestAemRepository, getToolDataToDownload: ToolDownloaderGetDataToDownload) {
        
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.attachmentsRepository = attachmentsRepository
        self.articleManifestAemRepository = articleManifestAemRepository
        self.getToolDataToDownload = getToolDataToDownload
    }
    
    private func downloadToolsWithProgressClosure(tools: [DownloadToolDataModel], requestPriority: RequestPriority, onProgress: ((_ dataModel: ToolDownloaderDataModel) -> Void), onComplete: (() -> Void)) async throws {
        
        let downloadData: ToolDownloaderDataToDownload = try getToolDataToDownload.getData(tools: tools)
        
        var downloadCount: Int = 0
        
        let totalNumberOfDownloads: Int = downloadData.nonArticleTranslations.count + downloadData.attachments.count + downloadData.articleTranslations.count
        
        for translation in downloadData.nonArticleTranslations {
            
            _ = try await translationsRepository.downloadAndCacheTranslationFiles(
                translation: translation,
                requestPriority: requestPriority
            )
            
            downloadCount += 1
        }
        
        for attachment in downloadData.attachments {
            
            _ = try await attachmentsRepository.downloadAndCacheAttachmentDataIfNeeded(
                attachment: attachment,
                requestPriority: requestPriority
            )
            
            downloadCount += 1
        }

        for translation in downloadData.articleTranslations {
         
            guard let languageCode = translation.languageDataModel?.code else {
                downloadCount += 1
                continue
            }
            
            let translationManifestDataModel = try await translationsRepository.getTranslationManifestFromCacheElseRemote(
                translation: translation,
                manifestParserType: .manifestOnly,
                requestPriority: requestPriority,
                includeRelatedFiles: true,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
            )

            _ = try await articleManifestAemRepository.downloadAndCacheManifestAemUris(
                manifest: translationManifestDataModel.manifest,
                translationId: translation.id,
                languageCode: languageCode,
                downloadCachePolicy: .ignoreCache,
                requestPriority: requestPriority
            )
            
            downloadCount += 1
        }
        
        let progress: Double
        
        if downloadCount >= totalNumberOfDownloads {
            progress = 1
        }
        else {
            progress = Double(downloadCount) / Double(totalNumberOfDownloads)
        }
        
        let dataModel = ToolDownloaderDataModel(
            attachments: downloadData.attachments,
            progress: progress,
            translations: downloadData.nonArticleTranslations + downloadData.articleTranslations
        )
        
        onProgress(dataModel)
        
        if downloadCount >= totalNumberOfDownloads {
            onComplete()
        }
    }
    
    func downloadToolsStream(tools: [DownloadToolDataModel], requestPriority: RequestPriority) -> AsyncThrowingStream<ToolDownloaderDataModel, Error> {
                
        return AsyncThrowingStream { continuation in
           
            Task {
                
                do {
                
                    try await downloadToolsWithProgressClosure(
                        tools: tools,
                        requestPriority: requestPriority,
                        onProgress: { (dataModel: ToolDownloaderDataModel) in
                            
                            continuation.yield(dataModel)
                        },
                        onComplete: {
                            
                            continuation.finish(throwing: nil)
                        })
                }
                catch let error {
                    
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func downloadTools(tools: [DownloadToolDataModel], requestPriority: RequestPriority) async throws {
        
        try await downloadToolsWithProgressClosure(
            tools: tools,
            requestPriority: requestPriority,
            onProgress: { _ in
            },
            onComplete: {
                
            })
    }
}
