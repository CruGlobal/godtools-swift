//
//  ChooseLanguageCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

class ChooseLanguageCellViewModel {
    
    private let language: LanguageDomainModel
    
    let languageName: String
    let hidesSelected: Bool
    let hidesSeparator: Bool
    let selectorColor: UIColor?
    let separatorColor: UIColor?
    let separatorLeftInset: Float
    let separatorRightInset: Float
    let languageLabelFontSize: Float?
    
    required init(language: LanguageDomainModel, hidesSelected: Bool, selectorColor: UIColor?, separatorColor: UIColor?, separatorLeftInset: Float?, separatorRightInset: Float?, languageLabelFontSize: Float?) {
        
        self.language = language
        self.languageName = language.translatedName
        self.hidesSelected = hidesSelected
        self.hidesSeparator = !hidesSelected
        self.selectorColor = selectorColor
        self.separatorColor = separatorColor
        self.separatorLeftInset = separatorLeftInset ?? 24
        self.separatorRightInset = separatorRightInset ?? 0
        self.languageLabelFontSize = languageLabelFontSize
    }
}
