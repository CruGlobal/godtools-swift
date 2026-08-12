//
//  GetUserAccountDetailsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class GetUserAccountDetailsUseCase {
    
    private let userDetailsRepository: UserDetailsRepository
    private let localizationServices: LocalizationServicesInterface
    
    init(userDetailsRepository: UserDetailsRepository, localizationServices: LocalizationServicesInterface) {
        
        self.userDetailsRepository = userDetailsRepository
        self.localizationServices = localizationServices
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<UserAccountDetailsDomainModel, Error> {

        userDetailsRepository
            .getAuthUserDetailsChangedPublisher(
                requestPriority: .high
            )
            .receive(on: DispatchQueue.global())
            .flatMap { (changedUserDetails: UserDetailsDataModel?) -> AnyPublisher<UserAccountDetailsDomainModel, Error> in

                return AnyPublisher() {

                    return try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> UserAccountDetailsDomainModel {
        
        let cachedAuthUserDetails: UserDetailsDataModel? = try userDetailsRepository.getAuthUserDetails()

        guard let cachedAuthUserDetails = cachedAuthUserDetails else {
            return UserAccountDetailsDomainModel.emptyValue
        }

        let accountDetails: UserAccountDetailsDomainModel = await mapUserDetails(
            userDetails: cachedAuthUserDetails,
            translatedInAppLanguage: appLanguage
        )

        return accountDetails
    }
}

extension GetUserAccountDetailsUseCase {
    
    private func mapUserDetails(userDetails: UserDetailsDataModel, translatedInAppLanguage: AppLanguageDomainModel) async -> UserAccountDetailsDomainModel {
        
        return UserAccountDetailsDomainModel(
            name: getName(userDetails: userDetails),
            joinedOnString: await getJoinedOnDate(userDetails: userDetails, translatedInAppLanguage: translatedInAppLanguage)
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
    
    private func getJoinedOnDate(userDetails: UserDetailsDataModel, translatedInAppLanguage: AppLanguageDomainModel) async -> String {
        
        guard let createdAtDate = userDetails.createdAt else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: translatedInAppLanguage)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let formattedCreatedAtDateString: String = dateFormatter.string(from: createdAtDate)
        
        let localizedJoinedOn: String = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: LocalizableStringKeys.accountJoinedOn.key)
        
        let joinedOnString: String = String.localizedStringWithFormat(localizedJoinedOn, formattedCreatedAtDateString)
        
        return joinedOnString
    }
}
