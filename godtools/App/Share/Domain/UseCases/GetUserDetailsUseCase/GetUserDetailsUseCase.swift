//
//  GetUserDetailsUserCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserDetailsUseCase {
    
    private let repository: UserDetailsRepository
    private let localizationServices: LocalizationServices
    
    init(repository: UserDetailsRepository, localizationServices: LocalizationServices) {
        
        self.repository = repository
        self.localizationServices = localizationServices
    }
    
    
    func getUserDetailsPublisher() -> AnyPublisher<UserDetailsDomainModel?, Never> {
        
        return Publishers.CombineLatest(fetchRemoteUserDetailsPublisher(), repository.getUserDetailsChanged())
            .flatMap { _ in
                
                guard let userDetails = self.repository.getAuthUserDetails() else {
                    
                    return Just<UserDetailsDomainModel?>(nil)
                        .eraseToAnyPublisher()
                }
                
                let joinedOnString = self.buildJoinedOnString(from: userDetails)
                
                return Just(UserDetailsDomainModel(joinedOnString: joinedOnString))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchRemoteUserDetailsPublisher() -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return repository.fetchRemoteUserDetails()
            .flatMap({ userDetailsDataModel -> AnyPublisher<UserDetailsDataModel?, URLResponseError> in
                
                return Just(userDetailsDataModel)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .catch { error in
                
                print("Error fetching remote user: \(error)")
                
                return Just<UserDetailsDataModel?>(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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
