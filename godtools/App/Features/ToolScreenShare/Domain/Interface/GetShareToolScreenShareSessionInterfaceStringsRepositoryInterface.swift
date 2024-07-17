//
//  GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolScreenShareSessionInterfaceStringsDomainModel, Never>
}
