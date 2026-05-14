//
//  DownloadToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DownloadToolLanguageUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(resourcesRepository: ResourcesRepository, toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.resourcesRepository = resourcesRepository
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    func execute(languageId: String) throws -> AsyncThrowingStream<Double, Error> {
        
        return try toolLanguageDownloader
            .downloadToolLanguage(languageId: languageId)
    }
}
