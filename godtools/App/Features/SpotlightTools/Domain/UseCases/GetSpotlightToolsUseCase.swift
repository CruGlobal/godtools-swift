//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetSpotlightToolsUseCase {
        
    private let getSpotlightToolsRepository: GetSpotlightToolsRepositoryInterface
    
    init(getSpotlightToolsRepository: GetSpotlightToolsRepositoryInterface) {

        self.getSpotlightToolsRepository = getSpotlightToolsRepository
    }
    
    func getSpotlightToolsPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> {
        
        return getSpotlightToolsRepository
            .getSpotlightToolsPublisher(translatedInAppLanguage: translatedInAppLanguage, languageIdForAvailabilityText: languageIdForAvailabilityText)
            .eraseToAnyPublisher()
    }
}
