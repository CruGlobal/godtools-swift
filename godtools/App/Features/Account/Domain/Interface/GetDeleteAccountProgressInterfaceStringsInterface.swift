//
//  GetDeleteAccountProgressInterfaceStringsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDeleteAccountProgressInterfaceStringsInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DeleteAccountProgressInterfaceStringsDomainModel, Never>
}
