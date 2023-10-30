//
//  GetToolDownloadProgressInterfaceStringUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDownloadProgressInterfaceStringUseCase {
    
    init() {
        
    }
    
    func getDownloadProgress(appLanguageCodeChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>, downloadProgressChangedPublisher: AnyPublisher<Double, Never>) -> AnyPublisher<ToolDownloadProgressDomainModel, Never> {
        
        return Publishers.CombineLatest(
            appLanguageCodeChangedPublisher.eraseToAnyPublisher(),
            downloadProgressChangedPublisher.eraseToAnyPublisher()
        )
        .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel, downloadProgress: Double) -> AnyPublisher<ToolDownloadProgressDomainModel, Never> in
            
            let downloadProgress = ToolDownloadProgressDomainModel(progress: downloadProgress, translateInLanguage: appLanguageCode)
            
            return Just(downloadProgress)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
