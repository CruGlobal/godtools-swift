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
        
        return Publishers.CombineLatest(fetchRemoteUserAccountDetailsPublisher(), repository.getUserDetailsChanged())
            .flatMap { _ in
                
                guard let userDetails = self.repository.getCachedAuthUserDetails() else {
                    
                    return Just(self.getDefaultUserAccountDetails())
                        .eraseToAnyPublisher()
                }
                
                let joinedOnString = self.buildJoinedOnString(from: userDetails)
                
                return Just(UserAccountDetailsDomainModel(joinedOnString: joinedOnString))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchRemoteUserAccountDetailsPublisher() -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return repository.fetchRemoteUserDetails()
            .flatMap({ userDetailsDataModel -> AnyPublisher<UserDetailsDataModel?, Error> in
                
                return Just(userDetailsDataModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .catch { error in
                
                print("Error fetching remote user: \(error)")
                
                return Just<UserDetailsDataModel?>(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getDefaultUserAccountDetails() -> UserAccountDetailsDomainModel {
        
        return UserAccountDetailsDomainModel(
            joinedOnString: ""
        )
    }
    
    private func buildJoinedOnString(from userDetails: UserDetailsDataModel) -> String {
        
        guard let createdAt = userDetails.createdAt else { return "" }
        
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
