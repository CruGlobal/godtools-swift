//
//  MobileContentParagraphViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentParagraphViewModelType {
    
    var visibilityState: ObservableValue<MobileContentViewVisibilityState> { get }
}
