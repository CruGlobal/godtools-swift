//
//  RendererPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol RendererPageViewModelType {
    
    // TODO: Not sure this should really be here. View should construct itself? ~Levi
    var content: ObservableValue<UIScrollView?> { get }
}
