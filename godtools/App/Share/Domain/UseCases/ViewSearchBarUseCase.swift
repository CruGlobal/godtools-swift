//
//  ViewSearchBarUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class ViewSearchBarUseCase {
    
    private let getSearchBarStrings: GetSearchBarStrings
    
    init(getSearchBarStrings: GetSearchBarStrings) {
        
        self.getSearchBarStrings = getSearchBarStrings
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewSearchBarDomainModel, Never> {
        
        return self.getSearchBarStrings
            .getStringsPublisher(translateInAppLanguage: appLanguage)
            .map {
                return ViewSearchBarDomainModel(strings: $0)
            }
            .eraseToAnyPublisher()
    }
}
