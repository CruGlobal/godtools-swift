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
    
    let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func downloadToolLanguage(_ appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> {
        
        return downloadedLanguagesRepository.storeDownloadedLanguagePublisher(languageId: appLanguage)
            .map { _ in
                
                return true
            }
            .catch { _ in

                return Just(false)
            }
            .eraseToAnyPublisher()
    }
}
