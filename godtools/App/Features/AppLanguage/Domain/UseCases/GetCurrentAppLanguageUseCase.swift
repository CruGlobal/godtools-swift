//
//  GetCurrentAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetCurrentAppLanguageUseCase {
    
    private let getAppLanguagesRepositoryInterface: GetAppLanguagesRepositoryInterface
    private let getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface
    private let getDeviceAppLanguageRepositoryInterface: GetDeviceAppLanguageRepositoryInterface
    
    init(getAppLanguagesRepositoryInterface: GetAppLanguagesRepositoryInterface, getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface, getDeviceAppLanguageRepositoryInterface: GetDeviceAppLanguageRepositoryInterface) {
        
        self.getAppLanguagesRepositoryInterface = getAppLanguagesRepositoryInterface
        self.getUserPreferredAppLanguageRepositoryInterface = getUserPreferredAppLanguageRepositoryInterface
        self.getDeviceAppLanguageRepositoryInterface = getDeviceAppLanguageRepositoryInterface
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        Publishers.Merge(
            getAppLanguagesRepositoryInterface.observeAppLanguagesChangedPublisher(),
            getUserPreferredAppLanguageRepositoryInterface.observeLanguageChangedPublisher()
        )
        .flatMap({ _ -> AnyPublisher<([AppLanguageDomainModel], AppLanguageDomainModel?), Never> in
            
            return Publishers.CombineLatest(
                self.getAppLanguagesRepositoryInterface.getAppLanguagesPublisher(),
                self.getUserPreferredAppLanguageRepositoryInterface.getLanguagePublisher()
            )
            .eraseToAnyPublisher()
        })
        .flatMap({ (appLanguages: [AppLanguageDomainModel], userAppLanguage: AppLanguageDomainModel?) -> AnyPublisher<AppLanguageDomainModel, Never> in

            if let userAppLanguage = userAppLanguage,
               let userAppLanguageIsAvailable = self.getAppLanguageIfAvailable(language: userAppLanguage, availableAppLanguages: appLanguages) {

                return Just(userAppLanguageIsAvailable)
                    .eraseToAnyPublisher()
            }

            return self.getDeviceLanguageElseEnglishPublisher(appLanguages: appLanguages)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getDeviceLanguageElseEnglishPublisher(appLanguages: [AppLanguageDomainModel]) -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        return getDeviceAppLanguageRepositoryInterface.getLanguagePublisher()
            .map { (deviceLanguage: AppLanguageDomainModel) in
                
                if let deviceLanguageIsAvailable = self.getAppLanguageIfAvailable(language: deviceLanguage, availableAppLanguages: appLanguages) {
                    return deviceLanguageIsAvailable
                }
                
                return LanguageCodeDomainModel.english.value
            }
            .eraseToAnyPublisher()
    }
    
    private func getAppLanguageIfAvailable(language: AppLanguageDomainModel?, availableAppLanguages: [AppLanguageDomainModel]) -> AppLanguageDomainModel? {
        
        guard let language = language else {
            return nil
        }
        
        return availableAppLanguages.first(where: {
            $0.lowercased() == language.lowercased()
        })
    }
}
