//
//  CustomViewBuilderType.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol CustomViewBuilderType {
    
    func buildCustomView(customViewId: String) -> UIView?
}
