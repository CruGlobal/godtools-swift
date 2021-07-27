//
//  MobileContentInputViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MobileContentInputViewModelType {
    
    var inputLabel: String? { get }
    var placeholder: String? { get }
    var isHidden: Bool { get }
    var isRequired: Bool { get }
    
    func inputChanged(text: String?)
    func getInputName() -> String?
    func getInputValue() -> String?
}
