//
//  ToolCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/09/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolCellViewModelType {
    
    var bannerImage: ObservableValue<UIImage?> { get }
    var attachmentsDownloadProgress: ObservableValue<Double> { get }
    var articlesDownloadProgress: ObservableValue<Double> { get }
    var translationDownloadProgress: ObservableValue<Double> { get }
    var title: ObservableValue<String> { get }
    var resourceDescription: ObservableValue<String> { get }
    var parallelLanguageName: ObservableValue<String> { get }
    var isFavorited: ObservableValue<Bool> { get }
    var aboutTitle: ObservableValue<String> { get }
    var openTitle: ObservableValue<String> { get }
}
