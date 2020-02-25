//
//  ImageCatalog.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum ImageCatalog: String {
    
    case navSettings = "nav_gear"
    
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
}
