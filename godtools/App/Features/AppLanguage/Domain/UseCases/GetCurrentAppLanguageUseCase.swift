//
//  GetCurrentAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetCurrentAppLanguageUseCase {
    
    private let getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface
    private let getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface
    private let getDeviceLanguageRepositoryInterface: GetDeviceLanguageRepositoryInterface
    
    init(getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface, getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface, getDeviceLanguageRepositoryInterface: GetDeviceLanguageRepositoryInterface) {
        
        self.getAppLanguagesListRepositoryInterface = getAppLanguagesListRepositoryInterface
        self.getUserPreferredAppLanguageRepositoryInterface = getUserPreferredAppLanguageRepositoryInterface
        self.getDeviceLanguageRepositoryInterface = getDeviceLanguageRepositoryInterface
    }
    
    func getAppLanguage() -> AppLanguageCodeDomainModel {

        let appLanguages: [AppLanguageCodeDomainModel] = getAppLanguagesListRepositoryInterface.getAppLanguagesList()

        let userPreferredAppLanguage: AppLanguageCodeDomainModel? = getUserPreferredAppLanguageRepositoryInterface.getUserPreferredAppLanguage()
        
        if let userAppLanguageIsAvailable = getAppLanguageIfAvailable(languageCode: userPreferredAppLanguage, availableAppLanguages: appLanguages) {
            return userAppLanguageIsAvailable
        }
        
        let deviceLanguageElseEnglish: AppLanguageCodeDomainModel = getDeviceLanguageElseEnglish(appLanguages: appLanguages)
        
        return deviceLanguageElseEnglish
    }

    private func getDeviceLanguageElseEnglish(appLanguages: [AppLanguageCodeDomainModel]) -> AppLanguageCodeDomainModel {
        
        let deviceLanguage: AppLanguageCodeDomainModel = getDeviceLanguageRepositoryInterface.getDeviceLanguage()
        
        if let deviceLanguageIsAvailable = getAppLanguageIfAvailable(languageCode: deviceLanguage, availableAppLanguages: appLanguages) {
            return deviceLanguageIsAvailable
        }
        
        return LanguageCodeDomainModel.english.value
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
