//
//  GetMenuInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetMenuInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<MenuInterfaceStringsDomainModel, Never>
}
