//
//  ToolDetailViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolDetailViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var topToolDetailMedia: ObservableValue<ToolDetailMedia?> { get }
    var hidesBannerImage: Bool { get }
    var hidesYoutubePlayer: Bool { get }
    var name: ObservableValue<String> { get }
    var totalViews: ObservableValue<String> { get }
    var openToolTitle: ObservableValue<String> { get }
    var unfavoriteTitle: ObservableValue<String> { get }
    var favoriteTitle: ObservableValue<String> { get }
    var hidesUnfavoriteButton: ObservableValue<Bool> { get }
    var hidesFavoriteButton: ObservableValue<Bool> { get }
    var toolDetailsControls: ObservableValue<[ToolDetailControl]> { get }
    var selectedDetailControl: ObservableValue<ToolDetailControl?> { get }
    var aboutDetails: ObservableValue<String> { get }
    var languageDetails: ObservableValue<String> { get }
    
    func pageViewed()
    func openToolTapped()
    func favoriteTapped()
    func unfavoriteTapped()
    func detailControlTapped(detailControl: ToolDetailControl)
    func urlTapped(url: URL)
}
