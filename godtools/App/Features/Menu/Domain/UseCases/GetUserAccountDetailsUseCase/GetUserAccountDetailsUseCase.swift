//
//  GetUserAccountDetailsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserAccountDetailsUseCase {
    
    private let repository: UserDetailsRepository
    private let localizationServices: LocalizationServices
    
    init(repository: UserDetailsRepository, localizationServices: LocalizationServices) {
        
        self.repository = repository
        self.localizationServices = localizationServices
    }
    
    func getUserAccountDetailsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<UserAccountDetailsDomainModel, Never> {
        
        return Publishers.CombineLatest3(
            repository.getAuthUserDetailsFromRemotePublisher().prepend(UserDetailsDataModel.emptyDataModel())
                .catch({ _ in
                    return Just(UserDetailsDataModel.emptyDataModel())
                        .eraseToAnyPublisher()
                }),
            repository.getAuthUserDetailsChangedPublisher().prepend(nil),
            appLanguagePublisher
        )
        .flatMap({ (remoteUserDetails: UserDetailsDataModel, changedUserDetails: UserDetailsDataModel?, appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserAccountDetailsDomainModel, Never> in
                            
            let cachedAuthUserDetails: UserDetailsDataModel? = self.repository.getCachedAuthUserDetails()
            
            guard let cachedAuthUserDetails = cachedAuthUserDetails else {
                return Just(self.getDefaultUserAccountDetails())
                    .eraseToAnyPublisher()
            }
            
            let accountDetails: UserAccountDetailsDomainModel = self.mapUserDetails(userDetails: cachedAuthUserDetails, translatedInAppLanguage: appLanguage)
                        
            return Just(accountDetails)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getDefaultUserAccountDetails() -> UserAccountDetailsDomainModel {
        
        return UserAccountDetailsDomainModel(
            name: "",
            joinedOnString: ""
        )
    }
    
    private func mapUserDetails(userDetails: UserDetailsDataModel, translatedInAppLanguage: AppLanguageDomainModel) -> UserAccountDetailsDomainModel {
        
        return UserAccountDetailsDomainModel(
            name: getName(userDetails: userDetails),
            joinedOnString: getJoinedOnDate(userDetails: userDetails, translatedInAppLanguage: translatedInAppLanguage)
        )
    }
    
    private func getName(userDetails: UserDetailsDataModel) -> String {
        
        if let name = userDetails.name, !name.isEmpty {
            return name
        }
        else if let firstName = userDetails.givenName, !firstName.isEmpty, let lastName = userDetails.familyName {
            return firstName + " " + lastName
        }
        else if let firstName = userDetails.givenName {
            return firstName
        }
        
        return ""
    }
    
    private func getJoinedOnDate(userDetails: UserDetailsDataModel, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        guard let createdAtDate = userDetails.createdAt else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: translatedInAppLanguage)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let formattedCreatedAtDateString: String = dateFormatter.string(from: createdAtDate)
        
        let localizedJoinedOn: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: "account.joinedOn")
        
        let joinedOnString: String = String.localizedStringWithFormat(localizedJoinedOn, formattedCreatedAtDateString)
        
        return joinedOnString
    }
}
