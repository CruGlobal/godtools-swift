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
                
                guard let realmUserDetails = self.repository.getUserDetails() else {
                    
                    return Just<UserDetailsDomainModel?>(nil)
                        .eraseToAnyPublisher()
                }
                
                var joinedOnString = ""
                if let createdAt = realmUserDetails.createdAt {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    
                    let joinedOnDateString = dateFormatter.string(from: createdAt)
                    
                    joinedOnString = String.localizedStringWithFormat(
                        self.localizationServices.stringForMainBundle(key: "account.joinedOn"),
                        joinedOnDateString
                    )
                }
                
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
}
