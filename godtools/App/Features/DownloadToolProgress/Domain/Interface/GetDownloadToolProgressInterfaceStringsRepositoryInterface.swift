//
//  GetDownloadToolProgressInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadToolProgressInterfaceStringsRepositoryInterface {
        
    func getStringsPublisher(toolId: String?, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never>
}
