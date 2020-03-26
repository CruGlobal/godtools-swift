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
    case tutorialInMenuEnglish = "tutorial_in_menu_english"
    case tutorialInMenuNonEnglish = "tutorial_in_menu_non_english"
    case tutorialToolEnglish = "tutorial_tool_english"
    case tutorialToolNonEnglish = "tutorial_tool_non_english"
    
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
    
    var name: String {
        return rawValue
    }
}
