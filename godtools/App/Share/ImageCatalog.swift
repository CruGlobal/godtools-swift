//
//  ImageCatalog.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

enum ImageCatalog: String {
    
    case accordionSectionPlus = "accordion_section_plus"
    case accordionSectionMinus = "accordion_section_minus"
    case circleSelectorBackground = "circle_selector_background"
    case favorited = "favorited"
    case favoritedCircle = "favorited_circle"
    case favoriteIcon = "favorite_icon"
    case languageAvailableCheck = "language_available_check"
    case languageUnavailableX = "language_unavailable_x"
    case launchImage = "LaunchImage"
    case lessonPageLeftArrow = "lesson_page_left_arrow"
    case lessonPageRightArrow = "lesson_page_right_arrow"
    case navBack = "nav_item_back"
    case navClose = "nav_item_close"
    case navHome = "home"
    case navLanguage = "nav_language"
    case navMenu = "nav_menu"
    case navSettings = "nav_gear"
    case navShare = "share"
    case navToolSettings = "nav_tool_settings"
    case nextCard = "next_card"
    case onboardingWelcomeLogo = "onboarding_welcome_logo"
    case openTutorialArrow = "open_tutorial_arrow"
    case notFavorited = "not_favorited"
    case playIcon = "play_icon"
    case previousCard = "previous_card"
    case rightArrowBlue = "right_arrow_blue"
    case toolSettingsLanguageDropDownArrow = "tool_settings_language_dropdown_arrow"
    case toolSettingsOptionHideTips = "tool_settings_option_hide_tips"
    case toolSettingsOptionScreenShare = "tool_settings_option_screen_share"
    case toolSettingsOptionShareLink = "tool_settings_option_share_link"
    case toolSettingsOptionTrainingTips = "tool_settings_option_training_tips"
    case toolSettingsOptionTrainingTipsBackground = "tool_settings_option_training_tip_background"
    case toolSettingsShareImageButtonIcon = "tool_settings_share_image_button_icon"
    case toolSettingsSwapLanguage = "tool_settings_swap_language"
    case toolsMenuLessons = "tools_menu_lessons"
    case toolsMenuFavorites = "tools_menu_favorites"
    case toolsMenuAllTools = "tools_menu_all_tools"
    case trainingTipAsk = "training_tip_ask"
    case trainingTipAskFilledRed = "training_tip_ask_filled_red"
    case trainingTipConsider = "training_tip_consider"
    case trainingTipConsiderFilledRed = "training_tip_consider_filled_red"
    case trainingTipPrepare = "training_tip_prepare"
    case trainingTipPrepareFilledRed = "training_tip_prepare_filled_red"
    case trainingTipQuote = "training_tip_quote"
    case trainingTipQuoteFilledRed = "training_tip_quote_filled_red"
    case trainingTipRedSquareBg = "training_tip_red_square_bg"
    case trainingTipSquareBg = "training_tip_square_bg"
    case trainingTipTip = "training_tip_tip"
    case trainingTipTipFilledRed = "training_tip_tip_filled_red"
    case tutorialInMenuEnglish = "tutorial_in_menu_english"
    case tutorialInMenuNonEnglish = "tutorial_in_menu_non_english"
    case tutorialTool = "tutorial_tool"
    case tutorialToolNonEnglish = "tutorial_tool_non_english"
    case tutorialPeople = "tutorial_people"
    case unfavoritedCircle = "unfavorited_circle"
    case unfavoriteIcon = "unfavorite_icon"
    
    var image: Image {
        return Image(name)
    }
    
    var uiImage: UIImage? {
        return UIImage(named: name)
    }
    
    var name: String {
        return rawValue
    }
}
