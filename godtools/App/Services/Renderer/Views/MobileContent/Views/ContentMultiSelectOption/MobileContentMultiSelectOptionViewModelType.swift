//
//  MobileContentMultiSelectOptionViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentMultiSelectOptionViewModelType {
    
    var backgroundColor: ObservableValue<UIColor> { get }
    var hidesShadow: Bool { get }
    
    func multiSelectOptionTapped()
}
