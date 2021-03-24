//
//  ToolPageHeaderViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageHeaderViewModelType {
    
    var hidesHeader: Bool { get }
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    var backgroundColor: UIColor { get }
    var number: String? { get }
    var numberFont: UIFont { get }
    var numberColor: UIColor { get }
    var numberAlignment: NSTextAlignment { get }
    var title: String? { get }
    var titleFont: UIFont { get }
    var titleColor: UIColor { get }
    var titleAlignment: NSTextAlignment { get }
    var trainingTipViewModel: TrainingTipViewModelType? { get }
}
