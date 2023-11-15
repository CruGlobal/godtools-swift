//
//  GetDownloadToolProgressInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadToolProgressInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetDownloadToolProgressInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetDownloadToolProgressInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(resource: ResourceModel?, appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> {
        
        appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface.getStringsPublisher(resource: resource, translateInAppLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
