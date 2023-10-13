//
//  GetAppLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAppLanguagesRepositoryInterface {
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageCodeDomainModel], Never>
    func observeAppLanguagesChangedPublisher() -> AnyPublisher<Void, Never>
}
