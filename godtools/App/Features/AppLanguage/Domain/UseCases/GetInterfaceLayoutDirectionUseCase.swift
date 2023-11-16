//
//  GetInterfaceLayoutDirectionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetInterfaceLayoutDirectionUseCase {
    
    private let getLayoutDirectionInterface: GetAppInterfaceLayoutDirectionInterface
    
    init(getLayoutDirectionInterface: GetAppInterfaceLayoutDirectionInterface) {
        
        self.getLayoutDirectionInterface = getLayoutDirectionInterface
    }
    
    func getLayoutDirectionPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<AppInterfaceLayoutDirectionDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppInterfaceLayoutDirectionDomainModel, Never> in
                
                return self.getLayoutDirectionInterface.getLayoutDirectionPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
