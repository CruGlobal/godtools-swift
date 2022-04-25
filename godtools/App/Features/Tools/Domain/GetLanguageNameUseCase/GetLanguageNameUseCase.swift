//
//  GetLanguageNameUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol GetLanguageNameUseCase {
    func getLanguageName(language: LanguageModel?) -> String
}
