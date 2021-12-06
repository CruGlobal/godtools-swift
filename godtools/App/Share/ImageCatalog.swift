//
//  ImageCatalog.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum ImageCatalog: String {
    
    case accordionSectionPlus = "accordion_section_plus"
    case accordionSectionMinus = "accordion_section_minus"
    case favorited = "favorited"
    case lessonPageLeftArrow = "lesson_page_left_arrow"
    case lessonPageRightArrow = "lesson_page_right_arrow"
    case navClose = "nav_item_close"
    case navBack = "nav_item_back"
    case navHome = "home"
    case navLanguage = "nav_language"
    case navMenu = "nav_menu"
    case navSettings = "nav_gear"
    case navShare = "share"
    case notFavorited = "not_favorited"
    case playIcon = "play_icon"
    case toolsMenuLessons = "tools_menu_lessons"
    case toolsMenuFavorites = "tools_menu_favorites"
    case toolsMenuAllTools = "tools_menu_all_tools"
    case tutorialInMenuEnglish = "tutorial_in_menu_english"
    case tutorialInMenuNonEnglish = "tutorial_in_menu_non_english"
    case tutorialTool = "tutorial_tool"
    case tutorialToolNonEnglish = "tutorial_tool_non_english"
    case tutorialPeople = "tutorial_people"
    
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
    
    var name: String {
        return rawValue
    }
}
