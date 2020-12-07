//
//  ViewObjectPoolType.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ViewObjectPoolType {
    
    func getReusableView() -> ReusableView
}
