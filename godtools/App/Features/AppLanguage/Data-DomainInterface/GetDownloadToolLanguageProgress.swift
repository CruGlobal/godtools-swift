//
//  GetDownloadToolLanguageProgress.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadToolLanguageProgress: GetDownloadToolLanguageProgressInterface {
    
    private let toolLanguageDownloader: ToolLanguageDownloader
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(toolLanguageDownloader: ToolLanguageDownloader, downloadedLanguagesRepository: DownloadedLanguagesRepository) {
        
        self.toolLanguageDownloader = toolLanguageDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func getProgressPublisher(languageId: String) -> AnyPublisher<DownloadToolLanguageProgressDomainModel, Never> {
        
        return toolLanguageDownloader
            .observeToolLanguageDownloadPublisher(languageId: languageId)
            .map { (download: ToolLanguageDownload) in
                                         
                let domainModel = DownloadToolLanguageProgressDomainModel(
                    dataModelId: languageId,
                    progress: download.downloadProgress
                )
                
                return domainModel
            }
            .eraseToAnyPublisher()
    }
}
