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

    private let getDeviceLanguageRepositoryInterface: GetDeviceLanguageRepositoryInterface

    init(getDeviceLanguageRepositoryInterface: GetDeviceLanguageRepositoryInterface) {
        
        self.getDeviceLanguageRepositoryInterface = getDeviceLanguageRepositoryInterface
    }
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
        
        return getDeviceLanguageRepositoryInterface.getDeviceLanguage()
    }
}
