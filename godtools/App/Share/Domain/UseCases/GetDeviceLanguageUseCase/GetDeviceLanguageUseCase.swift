//
//  GetDeviceLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDeviceLanguageUseCase {

    private let getDeviceLanguage: GetDeviceLanguageInterface

    init(getDeviceLanguage: GetDeviceLanguageInterface) {
        
        self.getDeviceLanguage = getDeviceLanguage
    }
    
    func getDeviceLanguagePublisher() -> AnyPublisher<DeviceLanguageDomainModel, Never> {
        
        return Just(getDeviceLanguageValue())
            .eraseToAnyPublisher()
    }
    
    func getDeviceLanguageValue() -> DeviceLanguageDomainModel {
                
        return getDeviceLanguage.getDeviceLanguage()
    }
}
