//
//  GetToolFilterCategoriesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolFilterCategoriesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterCategoriesInterfaceStringsDomainModel, Never>
}
