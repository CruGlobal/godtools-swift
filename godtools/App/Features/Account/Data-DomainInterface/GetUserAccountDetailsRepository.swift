//
//  GetUserAccountDetailsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import LocalizationServices

class GetUserAccountDetailsRepository: GetUserAccountDetailsRepositoryInterface {
    
    private let userDetailsRepository: UserDetailsRepository
    private let localizationServices: LocalizationServices
    
    init(userDetailsRepository: UserDetailsRepository, localizationServices: LocalizationServices) {
        self.userDetailsRepository = userDetailsRepository
        self.localizationServices = localizationServices
    }
    
    func getUserAccountDetailsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserAccountDetailsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            userDetailsRepository
                .getAuthUserDetailsFromRemotePublisher(requestPriority: .high)
                .prepend(UserDetailsDataModel.emptyDataModel())
                .catch({ _ in
                    return Just(UserDetailsDataModel.emptyDataModel())
                        .eraseToAnyPublisher()
                }),
            userDetailsRepository
                .getAuthUserDetailsChangedPublisher()
                .prepend(nil)
        )
        .flatMap({ (remoteUserDetails: UserDetailsDataModel, changedUserDetails: UserDetailsDataModel?) -> AnyPublisher<UserAccountDetailsDomainModel, Never> in
            
            let cachedAuthUserDetails: UserDetailsDataModel? = self.userDetailsRepository.getCachedAuthUserDetails()
            
            guard let cachedAuthUserDetails = cachedAuthUserDetails else {
                return Just(UserAccountDetailsDomainModel.emptyUserAccountDetails())
                    .eraseToAnyPublisher()
            }
            
            let accountDetails: UserAccountDetailsDomainModel = self.mapUserDetails(userDetails: cachedAuthUserDetails, translatedInAppLanguage: appLanguage)
            
            return Just(accountDetails)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}

// MARK: - Private

extension GetUserAccountDetailsRepository {
    
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

