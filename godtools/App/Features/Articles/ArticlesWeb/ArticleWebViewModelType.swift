//
//  ArticleWebViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

protocol ArticleWebViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var hidesShareButton: ObservableValue<Bool> { get }
    var isLoading: ObservableValue<Bool> { get }
    
    func pageViewed()
    func sharedTapped()
    func loadWebPage(webView: WKWebView)
}
