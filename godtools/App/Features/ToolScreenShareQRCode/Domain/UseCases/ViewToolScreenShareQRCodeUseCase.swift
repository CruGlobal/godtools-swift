//
//  ViewToolScreenShareQRCodeUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolScreenShareQRCodeUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface) {
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func viewQRCodePublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareQRCodeDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage)
            .map { interfaceStrings in
            
                ToolScreenShareQRCodeDomainModel(
                    interfaceStrings: interfaceStrings
                )
            }
            .eraseToAnyPublisher()
    }
}
