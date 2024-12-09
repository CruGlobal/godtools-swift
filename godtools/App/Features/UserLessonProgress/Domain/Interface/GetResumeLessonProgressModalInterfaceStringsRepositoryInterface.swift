//
//  GetResumeLessonProgressModalInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetResumeLessonProgressModalInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ResumeLessonProgressModalInterfaceStringsDomainModel, Never>
}
