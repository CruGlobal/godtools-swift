//
//  GetSpotlightToolsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetSpotlightToolsRepositoryInterface {
    
    @MainActor func getSpotlightToolsPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[SpotlightToolListItemDomainModel], Error>
}
