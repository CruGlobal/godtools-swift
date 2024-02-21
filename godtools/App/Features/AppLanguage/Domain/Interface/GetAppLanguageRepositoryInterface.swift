//
//  GetAppLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAppLanguageRepositoryInterface {
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never>
    func getLanguage() -> AppLanguageDomainModel
}
