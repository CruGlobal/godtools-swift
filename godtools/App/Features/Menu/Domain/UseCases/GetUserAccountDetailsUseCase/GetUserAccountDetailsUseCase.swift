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
            
            let accountDetails = UserAccountDetailsDomainModel(
                name: cachedAuthUserDetails.name ?? "",
                joinedOnString: self.buildJoinedOnString(from: cachedAuthUserDetails)
            )
                        
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
    
    private func buildJoinedOnString(from userDetails: UserDetailsDataModel) -> String {
        
        guard let createdAt = userDetails.createdAt else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let joinedOnDateString = dateFormatter.string(from: createdAt)
        
        let joinedOnString = String.localizedStringWithFormat(
            self.localizationServices.stringForMainBundle(key: "account.joinedOn"),
            joinedOnDateString
        )
        
        return joinedOnString
    }
}
