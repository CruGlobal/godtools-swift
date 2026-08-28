//
//  GetCreatingToolScreenShareSessionTimedOutStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetCreatingToolScreenShareSessionTimedOutStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> CreatingToolScreenShareSessionTimedOutStringsDomainModel {

        // TODO: Need to add these strings to crowdin. ~Levi
        
        return CreatingToolScreenShareSessionTimedOutStringsDomainModel(
            title: "Timed Out",
            message: "Timed out creating the session for tool screen share."
        )
    }
}
