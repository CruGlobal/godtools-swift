//
//  MockGetLanguageNameUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockGetLanguageNameUseCase: GetLanguageNameUseCase {
    func getLanguageName(language: LanguageModel?) -> String {
        return "French ✓"
    }
}
