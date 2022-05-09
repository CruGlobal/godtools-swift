//
//  ToolDetailViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolDetailViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var banner: ObservableValue<ToolDetailBanner> { get }
    var translationDownloadProgress: ObservableValue<Double> { get }
    var name: ObservableValue<String> { get }
    var totalViews: ObservableValue<String> { get }
    var openToolTitle: ObservableValue<String> { get }
    var unfavoriteTitle: ObservableValue<String> { get }
    var favoriteTitle: ObservableValue<String> { get }
    var hidesUnfavoriteButton: ObservableValue<Bool> { get }
    var hidesFavoriteButton: ObservableValue<Bool> { get }
    var learnToShareToolTitle: ObservableValue<String> { get }
    var hidesLearnToShareToolButton: ObservableValue<Bool> { get }
    var toolDetailsControls: ObservableValue<[ToolDetailControl]> { get }
    var selectedDetailControl: ObservableValue<ToolDetailControl?> { get }
    var aboutDetails: ObservableValue<String> { get }
    var languageDetails: ObservableValue<String> { get }
    
    func pageViewed()
    func openToolTapped()
    func favoriteTapped()
    func unfavoriteTapped()
    func learnToShareToolTapped()
    func detailControlTapped(detailControl: ToolDetailControl)
    func urlTapped(url: URL)
}
