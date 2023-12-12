//
//  GetDownloadableLanguagesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadableLanguagesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadableLanguagesInterfaceStringsDomainModel, Never>
}
