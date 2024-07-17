//
//  GetToolScreenShareTutorialInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolScreenShareTutorialInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareInterfaceStringsDomainModel, Never>
}
