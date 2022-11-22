//
//  GetMobileContentUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetMobileContentUserDetails {
    
    private let repository: MobileContentUserDetailsRepository
    private let localizationServices: LocalizationServices
    
    init(repository: MobileContentUserDetailsRepository, localizationServices: LocalizationServices) {
        
        self.repository = repository
        self.localizationServices = localizationServices
    }
    
    
    func getUserPublisher() -> AnyPublisher<UserDomainModel?, Never> {
        
        return Publishers.CombineLatest(fetchRemoteUserPublisher(), repository.getUserChanged())
            .flatMap { _ in
                
                guard let realmUser = self.repository.getUser() else {
                    
                    return Just<UserDomainModel?>(nil)
                        .eraseToAnyPublisher()
                }
                
                var joinedOnString = ""
                if let createdAt = realmUser.createdAt {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    
                    let joinedOnDateString = dateFormatter.string(from: createdAt)
                    
                    joinedOnString = String.localizedStringWithFormat(
                        self.localizationServices.stringForMainBundle(key: "account.joinedOn"),
                        joinedOnDateString
                    )
                }
                
                return Just(UserDomainModel(joinedOnString: joinedOnString))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchRemoteUserPublisher() -> AnyPublisher<UserDataModel?, Never> {
        
        return repository.fetchRemoteUserDetails()
            .flatMap({ userDataModel -> AnyPublisher<UserDataModel?, URLResponseError> in
                
                return Just(userDataModel)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .catch { error in
                
                print("Error fetching remote user: \(error)")
                
                return Just<UserDataModel?>(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
