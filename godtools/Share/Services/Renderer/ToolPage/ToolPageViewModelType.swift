//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolPageViewModelType {
    
    var headerNumber: String? { get }
    var headerTitle: String? { get }
    var hidesHeader: Bool { get }
    var hidesHero: Bool { get }
    var heroView: MobileContentStackView? { get }
    var callToActionTitle: String? { get }
    var hidesCallToAction: Bool { get }
}
