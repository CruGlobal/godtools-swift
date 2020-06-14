//
//  ToolCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolCellViewModelType {
    
    var bannerImage: ObservableValue<UIImage?> { get }
    var title: String { get }
    var resourceDescription: String { get }
    var isFavorited: Bool { get }
}
