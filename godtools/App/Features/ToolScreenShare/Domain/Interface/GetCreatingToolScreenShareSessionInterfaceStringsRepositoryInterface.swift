//
//  GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionInterfaceStringsDomainModel, Never>
}
