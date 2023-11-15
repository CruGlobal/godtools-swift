//
//  GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionTimedOutInterfaceStringsDomainModel, Never>
}
