//
//  GetAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageRepository: GetAppLanguageRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getLanguagePublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageDomainModel?, Never> {
        
        return appLanguagesRepository.getLanguagePublisher(languageCode: appLanguageCode)
            .map { (dataModel: AppLanguageDataModel?) in
                
                guard let dataModel = dataModel else {
                    return nil
                }
                
                return AppLanguageDomainModel(
                    languageCode: dataModel.languageCode,
                    languageDirection: dataModel.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
                )
            }
            .eraseToAnyPublisher()
    }
}
