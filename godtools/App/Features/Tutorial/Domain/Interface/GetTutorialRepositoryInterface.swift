//
//  GetTutorialRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetTutorialRepositoryInterface {
    
    func getTutorialPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[TutorialPageDomainModel], Never>
}
