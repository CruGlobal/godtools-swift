//
//  MobileContentViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentViewModelType {
    
    func render(didRenderView: ((_ mobileContentView: MobileContentView) -> Void))
}
