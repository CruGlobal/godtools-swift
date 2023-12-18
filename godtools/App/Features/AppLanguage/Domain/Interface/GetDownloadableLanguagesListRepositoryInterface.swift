//
//  GetDownloadableLanguagesListRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 12/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadableLanguagesListRepositoryInterface {
    
    func getDownloadableLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never>
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never>
}
