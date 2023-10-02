//
//  GetAppLanguageNameRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAppLanguageNameRepositoryInterface {
    
    func getLanguageNamePublisher(appLanguageCode: AppLanguageCodeDomainModel, translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never>
}
