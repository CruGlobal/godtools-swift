//
//  GetLessonFilterLanguagesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonFilterLanguagesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesInterfaceStringsDomainModel, Never>
}
