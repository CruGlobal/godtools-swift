//
//  ShareToolTutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareToolTutorialViewModelType {
        
    func closeTapped()
    func skipTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
}
