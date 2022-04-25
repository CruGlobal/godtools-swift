//
//  MockGetToolDataUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockGetToolDataUseCase: GetToolDataUseCase {
    let languageDirection: LanguageDirection
    
    init(languageDirection: LanguageDirection) {
        self.languageDirection = languageDirection
    }
    
    func getToolData() -> ToolDataModel {
        return ToolDataModel(title: "Tool Data Title", category: "Tool Category", languageDirection: languageDirection)
    }
}
