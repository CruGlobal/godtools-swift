//
//  GetLessonsInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonsInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonsInterfaceStringsDomainModel, Never>
}
