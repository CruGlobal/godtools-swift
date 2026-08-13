//
//  DownloadToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DownloadToolLanguageUseCase: Sendable {
    
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    @MainActor func execute(languageId: String) -> AnyPublisher<Double, Error> {
    
        return toolLanguageDownloader
            .downloadToolLanguagePublisher(languageId: languageId)
            .eraseToAnyPublisher()
    }
}
