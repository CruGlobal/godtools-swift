//
//  FontService.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class FontService {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
    }
    
    func getFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        // TODO: I think this needs to be a use case for fetching a font based on settings primary language. ~Levi
        
        guard let primaryLanguageCode = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier, !primaryLanguageCode.isEmpty else {
            return getDefaultFont(size: size, weight: weight)
        }

        let font: UIFont?
        
        if primaryLanguageCode == "am" {
            if weight == UIFont.Weight.semibold || weight == UIFont.Weight.bold {
                font = FontLibrary.notoSansEthiopicBold.uiFont(size: size)
            } else {
                font = FontLibrary.notoSansEthiopic.uiFont(size: size)
            }
        }
        else if primaryLanguageCode == "my" {
            if weight == UIFont.Weight.semibold || weight == UIFont.Weight.bold {
                font = FontLibrary.notoSansMyanmarBold.uiFont(size: size)
            } else {
                font = FontLibrary.notoSansMyanmar.uiFont(size: size)
            }
        }
        else {
            font = nil
        }
        
        return font ?? getDefaultFont(size: size, weight: weight)
    }
    
    private func getDefaultFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
