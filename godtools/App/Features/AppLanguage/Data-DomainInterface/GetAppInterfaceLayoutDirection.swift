//
//  GetAppInterfaceLayoutDirection.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppInterfaceLayoutDirection: GetAppInterfaceLayoutDirectionInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getLayoutDirectionPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppInterfaceLayoutDirectionDomainModel, Never> {
        
        return appLanguagesRepository.getLanguagePublisher(languageId: appLanguage)
            .map { (dataModel: AppLanguageDataModel?) in
                
                guard let dataModel = dataModel else {
                    return .leftToRight
                }
                
                return dataModel.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
            }
            .eraseToAnyPublisher()
    }
}
