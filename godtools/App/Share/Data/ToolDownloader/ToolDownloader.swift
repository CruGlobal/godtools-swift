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
    
    func downloadTools(tools: [DownloadToolData], requestPriority: RequestPriority) async throws {
        
        try await downloadToolsWithProgressClosure(
            tools: tools,
            requestPriority: requestPriority,
            onProgress: { _ in
            },
            onComplete: {
                
            })
    }
    
    func downloadToolsWithProgressClosure(tools: [DownloadToolData], requestPriority: RequestPriority, onProgress: ((_ progress: Double) -> Void), onComplete: (() -> Void)) async throws {
        
        let downloadData: ToolDownloaderDataToDownload = try getToolDataToDownload.getData(tools: tools)
        
        var downloadCount: Int = 0
        
        let totalNumberOfDownloads: Int = downloadData.nonArticleTranslations.count + downloadData.attachments.count + downloadData.articleTranslations.count
        
        try await downloadTranslations(translations: downloadData.nonArticleTranslations, requestPriority: requestPriority, onDownloaded: {
            
            downloadCount = incrementDownloadCount(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, updateProgress: onProgress)
        })
        
        try await downloadAttachments(attachments: downloadData.attachments, requestPriority: requestPriority, onDownloaded: {
            
            downloadCount = incrementDownloadCount(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, updateProgress: onProgress)
        })
        
        try await downloadTranslationsAndManifests(translations: downloadData.articleTranslations, requestPriority: requestPriority, onDownloaded: {
            
            downloadCount = incrementDownloadCount(downloadCount: downloadCount, totalNumberOfDownloads: totalNumberOfDownloads, updateProgress: onProgress)
        })
               
        onComplete()
    }
    
    private func incrementDownloadCount(downloadCount: Int, totalNumberOfDownloads: Int, updateProgress: ((_ progress: Double) -> Void)) -> Int {
        
        let newDownloadCount: Int = downloadCount + 1
        
        let progress: Double = getProgress(
            downloadCount: newDownloadCount,
            totalNumberOfDownloads: totalNumberOfDownloads
        )
        
        updateProgress(progress)
        
        return newDownloadCount
    }
    
    private func getProgress(downloadCount: Int, totalNumberOfDownloads: Int) -> Double {
        
        let progress: Double
        
        if downloadCount >= totalNumberOfDownloads {
            progress = 1
        }
        else {
            progress = Double(downloadCount) / Double(totalNumberOfDownloads)
        }
        
        return progress
    }
    
    private func downloadTranslations(translations: [TranslationDataModel], requestPriority: RequestPriority, onDownloaded: (() -> Void)) async throws {
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            for translation in translations {
                
                group.addTask {
                    
                    _ = try await self.translationsRepository.downloadAndCacheTranslationFiles(
                        translation: translation,
                        requestPriority: requestPriority
                    )
                }
            }
            
            for try await _ in group {
                onDownloaded()
            }
        }
    }
    
    private func downloadAttachments(attachments: [AttachmentDataModel], requestPriority: RequestPriority, onDownloaded: (() -> Void)) async throws {
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            for attachment in attachments {
                
                group.addTask {
                    
                    _ = try await self.attachmentsRepository.downloadAndCacheAttachmentDataIfNeeded(
                        attachment: attachment,
                        requestPriority: requestPriority
                    )
                }
            }
            
            for try await _ in group {
                onDownloaded()
            }
        }
    }
    
    private func downloadTranslationsAndManifests(translations: [TranslationDataModel], requestPriority: RequestPriority, onDownloaded: (() -> Void)) async throws {
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            for translation in translations {
                
                guard let languageCode = translation.languageDataModel?.code else {
                    onDownloaded()
                    continue
                }
                
                group.addTask {

                    let translationManifestDataModel = try await self.translationsRepository.getTranslationManifestFromCacheElseRemote(
                        translation: translation,
                        manifestParserType: .manifestOnly,
                        requestPriority: requestPriority,
                        includeRelatedFiles: true,
                        shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
                    )

                    _ = try await self.articleManifestAemRepository.downloadAndCacheManifestAemUris(
                        manifest: translationManifestDataModel.manifest,
                        translationId: translation.id,
                        languageCode: languageCode,
                        downloadCachePolicy: .ignoreCache,
                        requestPriority: requestPriority
                    )
                }
            }
            
            for try await _ in group {
                onDownloaded()
            }
        }
    }
}
