//
//  GetToolSettingsToolHasTipsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolSettingsToolHasTipsRepositoryInterface {
    
    func getHasTipsPublisher(toolId: String, toolLanguageId: String) -> AnyPublisher<Bool, Never>
}
