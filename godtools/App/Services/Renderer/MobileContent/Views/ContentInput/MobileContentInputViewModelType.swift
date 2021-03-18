//
//  MobileContentInputViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MobileContentInputViewModelType {
    
    var inputNode: ContentInputNode { get }
    var inputLabel: String? { get }
    var placeholder: String? { get }
    var inputValue: String? { get }
    
    func inputChanged(text: String?)
}
