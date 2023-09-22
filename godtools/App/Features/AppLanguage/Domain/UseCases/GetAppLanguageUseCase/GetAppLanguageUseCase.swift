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
    
    private let userAppLanguageRepository: GetUserAppLanguageRepositoryInterface
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    private let getAppLanguagesUseCase: GetAppLanguagesUseCase
    
    init(userAppLanguageRepository: GetUserAppLanguageRepositoryInterface, getDeviceLanguageUseCase: GetDeviceLanguageUseCase, getAppLanguagesUseCase: GetAppLanguagesUseCase) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
        self.getAppLanguagesUseCase = getAppLanguagesUseCase
    }
    
    func getAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
                        
        return Publishers.CombineLatest(
            getAppLanguagesUseCase.getAppLanguagesPublisher(),
            userAppLanguageRepository.getUserAppLanguagePublisher()
        )
        .flatMap({ (appLanguages: [AppLanguageDomainModel], userAppLanguage: AppLanguageDomainModel?) -> AnyPublisher<AppLanguageDomainModel, Never> in
            
            if let userAppLanguageIsAvailable = self.getAppLanguageIfAvailable(languageCode: userAppLanguage?.languageCode, availableAppLanguages: appLanguages) {
                
                return Just(userAppLanguageIsAvailable)
                    .eraseToAnyPublisher()
            }
            
            return self.getDeviceLanguageElseEnglishPublisher(appLanguages: appLanguages)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getDeviceLanguageElseEnglishPublisher(appLanguages: [AppLanguageDomainModel]) -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        return getDeviceLanguageUseCase.getDeviceLanguagePublisher()
            .flatMap({ (deviceLanguage: DeviceLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Never> in
                
                if let deviceLanguageIsAvailable = self.getAppLanguageIfAvailable(languageCode: deviceLanguage.languageCode, availableAppLanguages: appLanguages) {
                    
                    return Just(deviceLanguageIsAvailable)
                        .eraseToAnyPublisher()
                }
                    
                let englishAppLanguage = AppLanguageDomainModel(
                    direction: .leftToRight,
                    languageCode: LanguageCode.english.value
                )

                return Just(englishAppLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getAppLanguageIfAvailable(languageCode: String?, availableAppLanguages: [AppLanguageDomainModel]) -> AppLanguageDomainModel? {
        
        guard let languageCode = languageCode else {
            return nil
        }
        
        return availableAppLanguages.first(where: {
            $0.languageCode.lowercased() == languageCode.lowercased()
        })
    }
}
