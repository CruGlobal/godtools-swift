//
//  GetAppUILayoutDirectionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppUILayoutDirectionUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguageRepositoryInterface: GetAppLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageRepositoryInterface: GetAppLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageRepositoryInterface = getAppLanguageRepositoryInterface
    }
    
    func getLayoutDirectionPublisher() -> AnyPublisher<AppUILayoutDirectionDomainModel, Never> {
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap({ (currentAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageDomainModel?, Never> in
                
                return self.getAppLanguageRepositoryInterface.getLanguagePublisher(appLanguageCode: currentAppLanguageCode)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (appLanguage: AppLanguageDomainModel?) -> AnyPublisher<AppUILayoutDirectionDomainModel, Never> in
                
                let layoutDirection: AppUILayoutDirectionDomainModel
                
                if let appLanguage = appLanguage {
                    
                    layoutDirection = appLanguage.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
                }
                else {
                    
                    layoutDirection = .leftToRight
                }
                
                return Just(layoutDirection)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
