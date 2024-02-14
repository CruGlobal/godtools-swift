//
//  GetToolDetailsToolIsFavoritedRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolDetailsToolIsFavoritedRepositoryInterface {
    
    func getToolIsFavorited(tool: ToolDomainModel) -> AnyPublisher<Bool, Never>
}
