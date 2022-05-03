//
//  ToolBackButtonImageType+Image.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension ToolBackButtonImageType {
    
    func getImage() -> UIImage {
        switch self {
        case .backArrow:
            return ImageCatalog.navBack.image ?? UIImage()
        case .home:
            return ImageCatalog.navHome.image ?? UIImage()
        }
    }
}
