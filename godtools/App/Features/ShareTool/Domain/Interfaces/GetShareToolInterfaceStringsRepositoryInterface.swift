//
//  GetShareToolInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetShareToolInterfaceStringsRepositoryInterface {
    
    @MainActor func getStringsPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolInterfaceStringsDomainModel, Error>
}
