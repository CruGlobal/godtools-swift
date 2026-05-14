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
    
    private func updateProgress(downloadCount: Int, totalNumberOfDownloads: Int, onProgress: ((_ progress: Double) -> Void)) -> Double {
        
        let progress: Double
        
        if downloadCount >= totalNumberOfDownloads {
            progress = 1
        }
        else {
            progress = Double(downloadCount) / Double(totalNumberOfDownloads)
        }
        
        onProgress(progress)
        
        return progress
    }
    
    private func downloadToolsWithProgressClosure(tools: [DownloadToolData], requestPriority: RequestPriority, onProgress: ((_ progress: Double) -> Void), onComplete: (() -> Void)) async throws {
        
        let downloadData: ToolDownloaderDataToDownload = try getToolDataToDownload.getData(tools: tools)
        
        var downloadCount: Int = 0
        
        let totalNumberOfDownloads: Int = downloadData.nonArticleTranslations.count + downloadData.attachments.count + downloadData.articleTranslations.count
        
        for translation in downloadData.nonArticleTranslations {
            
            _ = try await translationsRepository.downloadAndCacheTranslationFiles(
                translation: translation,
                requestPriority: requestPriority
            )
            
            downloadCount += 1
            _ = updateProgress(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, onProgress: onProgress)
        }
        
        for attachment in downloadData.attachments {
            
            _ = try await attachmentsRepository.downloadAndCacheAttachmentDataIfNeeded(
                attachment: attachment,
                requestPriority: requestPriority
            )
            
            downloadCount += 1
            _ = updateProgress(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, onProgress: onProgress)
        }

        for translation in downloadData.articleTranslations {
         
            guard let languageCode = translation.languageDataModel?.code else {
                downloadCount += 1
                _ = updateProgress(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, onProgress: onProgress)
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
            _ = updateProgress(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, onProgress: onProgress)
        }
                     
        if downloadCount >= totalNumberOfDownloads {
            onComplete()
        }
    }
    
    func downloadToolsStream(tools: [DownloadToolData], requestPriority: RequestPriority) -> AsyncThrowingStream<Double, Error> {
                
        return AsyncThrowingStream { continuation in
           
            Task {
                
                do {
                
                    try await downloadToolsWithProgressClosure(
                        tools: tools,
                        requestPriority: requestPriority,
                        onProgress: { (progress: Double) in
                                                        
                            continuation.yield(progress)
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
    
    func downloadTools(tools: [DownloadToolData], requestPriority: RequestPriority) async throws {
        
        try await downloadToolsWithProgressClosure(
            tools: tools,
            requestPriority: requestPriority,
            onProgress: { _ in
            },
            onComplete: {
                
            })
    }
}
