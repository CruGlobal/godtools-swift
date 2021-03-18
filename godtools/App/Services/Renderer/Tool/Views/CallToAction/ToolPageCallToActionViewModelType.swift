//
//  ToolPageCallToActionViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCallToActionViewModelType {
    
    var hidesCallToAction: Bool { get }
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    var title: String? { get }
    var titleFont: UIFont { get }
    var titleColor: UIColor { get }
    var nextButtonColor: UIColor { get }
    var nextButtonImage: UIImage? { get }
}
