//
//  ToolPageContentFormViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolPageContentFormViewModelType {
    
    var resignCurrentInputSignal: Signal { get }
    var contentViewModel: ToolPageContentStackViewModel { get }
}
