//
//  DownloadToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadToolLanguageUseCase {
    
    private let downloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface
    
    init(downloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface) {
        
        self.downloadToolLanguageRepository = downloadToolLanguageRepository
    }
    
    func downloadToolLanguage(languageId: String) -> AnyPublisher<Double, Error> {
        
        return downloadToolLanguageRepository.downloadToolTranslations(for: languageId)
    }
}
