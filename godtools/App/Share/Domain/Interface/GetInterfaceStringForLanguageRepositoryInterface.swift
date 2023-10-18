//
//  GetInterfaceStringForLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetInterfaceStringForLanguageRepositoryInterface {
    
    func getString(languageCode: String, stringId: String) -> String
    func getStringPublisher(languageCode: String, stringId: String) -> AnyPublisher<String, Never>
}
