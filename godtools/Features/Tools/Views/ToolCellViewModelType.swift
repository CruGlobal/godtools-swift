//
//  ToolCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolCellViewModelType {
    
    var bannerImage: ObservableValue<UIImage?> { get }
    var attachmentsDownloadProgress: ObservableValue<Double> { get }
    var articlesDownloadProgress: ObservableValue<Double> { get }
    var translationDownloadProgress: ObservableValue<Double> { get }
    var title: String { get }
    var resourceDescription: String { get }
    var primaryLanguageName: ObservableValue<String> { get }
    var primaryLanguageColor: ObservableValue<UIColor> { get }
    var parallelLanguageName: ObservableValue<String> { get }
    var parallelLanguageColor: ObservableValue<UIColor> { get }
    var isFavorited: ObservableValue<Bool> { get }
}
