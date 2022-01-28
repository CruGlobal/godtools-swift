//
//  ChooseLanguageCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

protocol ChooseLanguageCellViewModelType {
    
    var languageName: String { get }
    var languageIsDownloaded: Bool { get }
    var hidesSelected: Bool { get }
    var hidesSeparator: Bool { get }
    var separatorLeftInset: Float { get }
    var separatorRightInset: Float { get }
    var languageLabelFontSize: Float? { get }
    var selectorColor: UIColor? { get }
    var separatorColor: UIColor? { get }
}
