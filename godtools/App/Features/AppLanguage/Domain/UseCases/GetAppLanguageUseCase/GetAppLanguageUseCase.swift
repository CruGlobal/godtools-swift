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
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(userAppLanguageRepository: GetUserAppLanguageRepositoryInterface, getDeviceLanguageUseCase: GetDeviceLanguageUseCase, getAppLanguagesUseCase: GetAppLanguagesUseCase, getLanguageUseCase: GetLanguageUseCase) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
        self.getAppLanguagesUseCase = getAppLanguagesUseCase
        self.getLanguageUseCase = getLanguageUseCase
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
        .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Never> in
            
            let direction: LanguageDirectionDomainModel
            
            if let language = self.getLanguageUseCase.getLanguage(languageCode: appLanguage.languageCode) {
                direction = language.direction
            }
            else {
                direction = .leftToRight
            }
            
            return Just(appLanguage.copy(direction: direction))
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
