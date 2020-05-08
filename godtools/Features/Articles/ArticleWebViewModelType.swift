//
//  ArticleWebViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleWebViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var hidesShareButton: ObservableValue<Bool> { get }
    var webUrl: ObservableValue<URL?> { get }
    var webArchiveUrl: ObservableValue<URL?> { get }
    
    func pageViewed()
    func sharedTapped()
}
