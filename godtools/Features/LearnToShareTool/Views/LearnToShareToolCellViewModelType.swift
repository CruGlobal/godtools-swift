//
//  LearnToShareToolCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LearnToShareToolCellViewModelType {
    
    var imageName: String? { get }
    var animationName: String? { get }
    var title: String { get }
    var message: String { get }
}
