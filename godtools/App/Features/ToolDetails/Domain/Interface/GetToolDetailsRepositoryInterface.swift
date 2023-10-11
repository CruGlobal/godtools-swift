//
//  GetToolDetailsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolDetailsRepositoryInterface {
    
    func getDetailsPublisher(tool: ToolDomainModel, translateInToolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never>
}
