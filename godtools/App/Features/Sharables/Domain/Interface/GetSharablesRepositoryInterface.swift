//
//  GetSharablesRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetSharablesRepositoryInterface {
    
    func getSharablesPublisher(resource: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[SharableDomainModel], Never>
}
