//
//  GetSocialSignInInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetSocialSignInInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<SocialSignInInterfaceStringsDomainModel, Never>
}
