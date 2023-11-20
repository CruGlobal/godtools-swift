//
//  GetSocialCreateAccountInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetSocialCreateAccountInterfaceStringsRepositoryInterface {

    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<SocialCreateAccountInterfaceStringsDomainModel, Never>
}
