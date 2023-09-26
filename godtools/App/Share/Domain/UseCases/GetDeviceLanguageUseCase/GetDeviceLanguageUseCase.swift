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

    private let getDeviceAppLanguageRepositoryInterface: GetDeviceAppLanguageRepositoryInterface

    init(getDeviceAppLanguageRepositoryInterface: GetDeviceAppLanguageRepositoryInterface) {
        
        self.getDeviceAppLanguageRepositoryInterface = getDeviceAppLanguageRepositoryInterface
    }
    
    func getDeviceLanguagePublisher() -> AnyPublisher<DeviceLanguageDomainModel, Never> {
        
        return Just(getDeviceLanguageValue())
            .eraseToAnyPublisher()
    }
    
    func getDeviceLanguageValue() -> DeviceLanguageDomainModel {
                
        let languageCode: String = getDeviceAppLanguageRepositoryInterface.getDeviceAppLanguage()
        
        return DeviceLanguageDomainModel(languageCode: languageCode)
    }
}
