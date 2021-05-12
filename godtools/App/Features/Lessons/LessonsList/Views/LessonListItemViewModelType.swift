//
//  LessonListItemViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol LessonListItemViewModelType: ToolItemInitialDownloadProgress {
    
    var title: ObservableValue<String> { get }
    var bannerImage: ObservableValue<UIImage?> { get }
}
