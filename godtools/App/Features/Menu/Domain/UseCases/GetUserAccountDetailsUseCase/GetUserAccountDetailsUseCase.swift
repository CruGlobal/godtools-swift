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
    
    
    func getUserAccountDetailsPublisher() -> AnyPublisher<UserAccountDetailsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            repository.getAuthUserDetailsFromRemotePublisher().prepend(UserDetailsDataModel.emptyDataModel())
                .catch({ _ in
                    return Just(UserDetailsDataModel.emptyDataModel())
                        .eraseToAnyPublisher()
                }),
            repository.getAuthUserDetailsChangedPublisher().prepend(nil)
        )
        .flatMap({ (remoteUserDetails: UserDetailsDataModel, changedUserDetails: UserDetailsDataModel?) -> AnyPublisher<UserAccountDetailsDomainModel, Never> in
                            
            let cachedAuthUserDetails: UserDetailsDataModel? = self.repository.getCachedAuthUserDetails()
            
            guard let cachedAuthUserDetails = cachedAuthUserDetails else {
                return Just(self.getDefaultUserAccountDetails())
                    .eraseToAnyPublisher()
            }
            
            let accountDetails: UserAccountDetailsDomainModel = self.mapUserDetails(userDetails: cachedAuthUserDetails)
                        
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
    
    private func mapUserDetails(userDetails: UserDetailsDataModel) -> UserAccountDetailsDomainModel {
        
        return UserAccountDetailsDomainModel(
            name: getName(userDetails: userDetails),
            joinedOnString: getJoinedOnDate(userDetails: userDetails)
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
    
    private func getJoinedOnDate(userDetails: UserDetailsDataModel) -> String {
        
        guard let createdAtDate = userDetails.createdAt else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let formattedCreatedAtDateString: String = dateFormatter.string(from: createdAtDate)
        
        let joinedOnString: String = String.localizedStringWithFormat(localizationServices.stringForMainBundle(key: "account.joinedOn"), formattedCreatedAtDateString)
        
        return joinedOnString
    }
}
