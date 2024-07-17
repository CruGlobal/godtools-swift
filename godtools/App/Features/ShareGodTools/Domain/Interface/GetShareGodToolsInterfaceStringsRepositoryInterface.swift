//
//  GetShareGodToolsInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetShareGodToolsInterfaceStringsRepositoryInterface {
    
    func getInterfaceStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareGodToolsInterfaceStringsDomainModel, Never>
}
