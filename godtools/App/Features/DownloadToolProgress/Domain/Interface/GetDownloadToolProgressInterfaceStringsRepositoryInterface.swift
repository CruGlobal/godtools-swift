//
//  GetDownloadToolProgressInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadToolProgressInterfaceStringsRepositoryInterface {
    
    // TODO: Eventually ToolDomainModel should be passed in here and used to look up the ResourceModel. ~Levi
    
    func getStringsPublisher(resource: ResourceModel?, translateInAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never>
}
