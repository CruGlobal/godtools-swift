//
//  ToolShortcutLinksView.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolShortcutLinksView {
    
    enum ShortcutItemType: String {
        case tool
    }
    
    enum ShortcutItemUserInfoKey: String {
        case toolDeepLinkUrl = "tool_app_deep_link_url"
    }
    
    private static var shortcutLinksCancellable: AnyCancellable?
    
    private let application: UIApplication
    private let viewModel: ToolShortcutLinksViewModel
    
    init(application: UIApplication, viewModel: ToolShortcutLinksViewModel) {
        
        self.application = application
        self.viewModel = viewModel
        
        ToolShortcutLinksView.shortcutLinksCancellable = viewModel.$shortcutLinks
            .receive(on: DispatchQueue.main)
            .sink { (toolShortcutLinks: [ToolShortcutLinkDomainModel]) in
                
                let toolShortcutItems = toolShortcutLinks.map({ (toolShortcutLink: ToolShortcutLinkDomainModel) in
                    
                    UIApplicationShortcutItem(
                        type: ShortcutItemType.tool.rawValue,
                        localizedTitle: toolShortcutLink.title,
                        localizedSubtitle: nil,
                        icon: nil,
                        userInfo: [ShortcutItemUserInfoKey.toolDeepLinkUrl.rawValue: toolShortcutLink.appDeepLinkUrl as NSSecureCoding]
                    )
                })
                
                application.shortcutItems = toolShortcutItems
            }
    }
    
    static func getToolDeepLinkUrl(shortcutItem: UIApplicationShortcutItem) -> String? {
        
        return shortcutItem.userInfo?[ShortcutItemUserInfoKey.toolDeepLinkUrl.rawValue] as? String
    }
}
