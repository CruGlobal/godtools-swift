//
//  GetInterfaceStringUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//
import Foundation
import Combine

class GetInterfaceStringUseCase {

    private let interfaceStringRepository: GetInterfaceStringRepositoryInterface
    private let getAppLanguageUseCase: GetAppLanguageUseCase

    init(interfaceStringRepository: GetInterfaceStringRepositoryInterface, getAppLanguageUseCase: GetAppLanguageUseCase) {

        self.interfaceStringRepository = interfaceStringRepository
        self.getAppLanguageUseCase = getAppLanguageUseCase
    }

    func getString(id: String) -> String {
        
        // TODO: For now will just return string from English, but will need to update this to base it on the app language. ~Levi
        
        return interfaceStringRepository.getStringForLanguage(languageCode: LanguageCode.english.value, stringId: id)
    }
    
    // TODO: Remvoe this method, but this example fetches based on the app language.  Need to persist app languages so we don't have to use a publisher. ~Levi
    /*
    func getStringPublisher(id: String) -> AnyPublisher<String, Never> {

        return getAppLanguageUseCase.getAppLanguagePublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<String, Never> in
                
                return self.interfaceStringRepository.getStringForLanguagePublisher(languageCode: appLanguage.languageCode, stringId: id)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }*/
}
