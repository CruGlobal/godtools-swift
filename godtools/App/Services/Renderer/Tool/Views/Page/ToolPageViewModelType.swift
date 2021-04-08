//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType {
    
    var backgroundColor: UIColor { get }
    var bottomViewColor: UIColor { get }
    var page: Int { get }
    var hidesCallToAction: Bool { get }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel?
    func callToActionWillAppear() -> ToolPageCallToActionView?
    func pageDidAppear()
}
