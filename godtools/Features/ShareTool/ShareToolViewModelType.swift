//
//  ShareToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareToolViewModelType {
    
    var shareMessage: String { get }
    
    func pageViewed()
}
