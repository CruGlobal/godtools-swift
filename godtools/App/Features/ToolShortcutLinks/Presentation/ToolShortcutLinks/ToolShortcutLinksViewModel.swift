//
//  ToolShortcutLinksViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolShortcutLinksViewModel: ObservableObject {
    
    enum ShortcutItemType: String {
        case tool
    }
    
    enum ShortcutItemUserInfoKey: String {
        case toolDeepLinkUrl = "tool_app_deep_link_url"
    }
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolShortcutLinksUseCase: ViewToolShortcutLinksUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var shortcutLinks: [UIApplicationShortcutItem] = Array()
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolShortcutLinksUseCase: ViewToolShortcutLinksUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolShortcutLinksUseCase = viewToolShortcutLinksUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolShortcutLinksDomainModel, Never> in
                
                viewToolShortcutLinksUseCase
                    .viewPublisher(appLanguage: appLanguage)
            })
            .sink { [weak self] (domainModel: ViewToolShortcutLinksDomainModel) in
                
                self?.shortcutLinks = domainModel.shortcutLinks.map({ (toolShortcutLink: ToolShortcutLinkDomainModel) in
                    
                    UIApplicationShortcutItem(
                        type: ShortcutItemType.tool.rawValue,
                        localizedTitle: toolShortcutLink.title,
                        localizedSubtitle: nil,
                        icon: nil,
                        userInfo: [ShortcutItemUserInfoKey.toolDeepLinkUrl.rawValue: toolShortcutLink.appDeepLinkUrl as NSSecureCoding]
                    )
                })
            }
            .store(in: &cancellables)
    }
    
    static func getToolDeepLinkUrl(shortcutItem: UIApplicationShortcutItem) -> String? {
        return shortcutItem.userInfo?[ShortcutItemUserInfoKey.toolDeepLinkUrl.rawValue] as? String
    }
}
