//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetSpotlightToolsUseCase {
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    
    init(getAllToolsUseCase: GetAllToolsUseCase) {
        self.getAllToolsUseCase = getAllToolsUseCase
    }
    
    func getAllSpotlightTools() -> [ToolDomainModel] {

        return getAllToolsUseCase.getAllTools(andFilteredBy: { $0.attrSpotlight })
    }
}
