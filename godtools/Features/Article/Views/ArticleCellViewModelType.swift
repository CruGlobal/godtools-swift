//
//  ArticleCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ArticleCellViewModelType {
    
    var articleImage: ObservableValue<UIImage?> { get }
    var title: ObservableValue<String?> { get }
}
