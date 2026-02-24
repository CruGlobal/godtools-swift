//
//  FavoritesStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct FavoritesStringsDomainModel: Sendable {
    
    let tutorialMessage: String
    let openTutorialActionTitle: String
    let welcomeTitle: String
    let featuredLessonsTitle: String
    let favoriteToolsTitle: String
    let viewAllFavoritesActionTitle: String
    let noFavoritedToolsTitle: String
    let noFavoritedToolsDescription: String
    let noFavoritedToolsActionTitle: String
    
    static var emptyValue: FavoritesStringsDomainModel {
        return FavoritesStringsDomainModel(tutorialMessage: "", openTutorialActionTitle: "", welcomeTitle: "", featuredLessonsTitle: "", favoriteToolsTitle: "", viewAllFavoritesActionTitle: "", noFavoritedToolsTitle: "", noFavoritedToolsDescription: "", noFavoritedToolsActionTitle: "")
    }
}
