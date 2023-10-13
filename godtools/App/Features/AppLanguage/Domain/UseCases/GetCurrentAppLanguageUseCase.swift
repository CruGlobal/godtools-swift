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
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageCodeDomainModel, Never> {
        
        Publishers.Merge(
            getAppLanguagesRepositoryInterface.observeAppLanguagesChangedPublisher(),
            getUserPreferredAppLanguageRepositoryInterface.observeLanguageChangedPublisher()
        )
        .flatMap({ _ -> AnyPublisher<([AppLanguageCodeDomainModel], AppLanguageCodeDomainModel?), Never> in
            
            return Publishers.CombineLatest(
                self.getAppLanguagesRepositoryInterface.getAppLanguagesPublisher(),
                self.getUserPreferredAppLanguageRepositoryInterface.getLanguagePublisher()
            )
            .eraseToAnyPublisher()
        })
        .flatMap({ (appLanguages: [AppLanguageCodeDomainModel], userAppLanguage: AppLanguageCodeDomainModel?) -> AnyPublisher<AppLanguageCodeDomainModel, Never> in

            if let userAppLanguage = userAppLanguage,
               let userAppLanguageIsAvailable = self.getAppLanguageIfAvailable(languageCode: userAppLanguage, availableAppLanguages: appLanguages) {

                return Just(userAppLanguageIsAvailable)
                    .eraseToAnyPublisher()
            }

            return self.getDeviceLanguageElseEnglishPublisher(appLanguages: appLanguages)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getDeviceLanguageElseEnglishPublisher(appLanguages: [AppLanguageCodeDomainModel]) -> AnyPublisher<AppLanguageCodeDomainModel, Never> {
        
        return getDeviceAppLanguageRepositoryInterface.getLanguagePublisher()
            .map { (deviceLanguage: AppLanguageCodeDomainModel) in
                
                if let deviceLanguageIsAvailable = self.getAppLanguageIfAvailable(languageCode: deviceLanguage, availableAppLanguages: appLanguages) {
                    return deviceLanguageIsAvailable
                }
                
                return LanguageCodeDomainModel.english.value
            }
            .eraseToAnyPublisher()
    }
    
    private func getAppLanguageIfAvailable(languageCode: AppLanguageCodeDomainModel?, availableAppLanguages: [AppLanguageCodeDomainModel]) -> AppLanguageCodeDomainModel? {
        
        guard let languageCode = languageCode else {
            return nil
        }
        
        return availableAppLanguages.first(where: {
            $0.lowercased() == languageCode.lowercased()
        })
    }
}
