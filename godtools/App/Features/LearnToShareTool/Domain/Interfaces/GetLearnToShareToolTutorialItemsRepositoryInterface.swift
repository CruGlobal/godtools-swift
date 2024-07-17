//
//  GetLearnToShareToolTutorialItemsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLearnToShareToolTutorialItemsRepositoryInterface {
    
    func getItemsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[LearnToShareToolItemDomainModel], Never>
}
