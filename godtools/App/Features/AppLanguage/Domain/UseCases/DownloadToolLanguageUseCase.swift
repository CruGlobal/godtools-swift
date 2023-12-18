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
    
    let downloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface
    
    init(downloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface) {
        
        self.downloadToolLanguageRepository = downloadToolLanguageRepository
    }
    
    func downloadToolLanguage(_ appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> {
        
        return downloadToolLanguageRepository.downloadToolLanguage(languageId: appLanguage)
    }
}
