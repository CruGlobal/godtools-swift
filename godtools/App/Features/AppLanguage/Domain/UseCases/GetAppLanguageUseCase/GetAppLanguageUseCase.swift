//
//  GetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageUseCase {
    
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(getDeviceLanguageUseCase: GetDeviceLanguageUseCase, getLanguageUseCase: GetLanguageUseCase) {
        
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getAppLanguagePublisher() -> AnyPublisher<LanguageDomainModel?, Never> {
        
        // TODO: We need to be able to persist the user's preferred app language in a repository class once we implement the use case for choosing an app language and fetch from here. ~Levi
        // TODO: If an app language is not peristed in the user's preferred app language repository class, then we will attempt to fallback to the device language if it's an available app language. ~Levi
        // TODO: For now we will default to the device language, but we will need to verify the device language is indeed an app language.  If the device language is not an available app language then we will fallback to English. ~Levi
        
        return getDeviceLanguageUseCase.getDeviceLanguagePublisher()
            .flatMap({ (deviceLanguage: DeviceLanguageDomainModel) -> AnyPublisher<LanguageDomainModel?, Never> in
                
                if let language = deviceLanguage.language {
                    
                    return Just(language)
                        .eraseToAnyPublisher()
                }
                
                return self.getLanguageUseCase.getLanguagePublisher(languageCode: LanguageCode.english.value)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
