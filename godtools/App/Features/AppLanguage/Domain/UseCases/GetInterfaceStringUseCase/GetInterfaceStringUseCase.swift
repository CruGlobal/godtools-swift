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

    func getStringPublisher(id: String) -> AnyPublisher<String, Never> {

        return getAppLanguageUseCase.getAppLanguagePublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<String, Never> in
                
                return self.interfaceStringRepository.getStringForLanguagePublisher(languageCode: appLanguage.languageCode, stringId: id)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
