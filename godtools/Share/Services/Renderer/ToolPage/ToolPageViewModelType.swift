//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType {
    
    var backgroundImage: UIImage? { get }
    var hidesBackgroundImage: Bool { get }
    var contentStack: ObservableValue<ToolPageContentStackView?> { get }
    var headerNumber: String? { get }
    var headerTitle: String? { get }
    var hidesHeader: Bool { get }
    var hero: ObservableValue<ToolPageContentStackView?> { get }
    var callToActionTitle: String? { get }
    var callToActionTitleColor: UIColor { get }
    var callToActionNextButtonColor: UIColor { get }
    var hidesCallToAction: Bool { get }
    
    func headerWillAppear() -> ToolPageHeaderViewModel
    func callToActionWillAppear()
}
