//
//  GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface {
    
    func getIsAvailablePublisher(toolId: String, primaryLanguage: BCP47LanguageIdentifier, parallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<Bool, Never>
}
