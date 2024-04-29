//
//  GetSpiritualConversationReadinessScaleInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetSpiritualConversationReadinessScaleInterface {
    
    func getScalePublisher(scale: Int, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SpiritualConversationReadinessScaleDomainModel, Never>
}
