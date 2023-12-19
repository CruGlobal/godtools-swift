//
//  StoreToolSettingsParallelLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreToolSettingsParallelLanguageRepositoryInterface {
    
    func storeLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never>
}
