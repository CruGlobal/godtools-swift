//
//  ToolPageHeaderViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageHeaderViewModelType: MobileContentViewModelType {
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    var backgroundColor: UIColor { get }
    
    func getNumber(numberLabel: UILabel) -> MobileContentTextView?
    func getTitle(titleLabel: UILabel) -> MobileContentTextView?
}
