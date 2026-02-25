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

@MainActor class ToolShortcutLinksViewModel: ObservableObject {
    
    enum ShortcutItemType: String {
        case tool
    }
    
    enum ShortcutItemUserInfoKey: String {
        case toolDeepLinkUrl = "tool_app_deep_link_url"
    }
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolShortcutLinksUseCase: GetToolShortcutLinksUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var shortcutLinks: [UIApplicationShortcutItem] = Array()
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolShortcutLinksUseCase: GetToolShortcutLinksUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolShortcutLinksUseCase = getToolShortcutLinksUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never> in
                
                getToolShortcutLinksUseCase
                    .execute(appLanguage: appLanguage)
            })
            .sink { [weak self] (shortcutLinks: [ToolShortcutLinkDomainModel]) in
                
                self?.shortcutLinks = shortcutLinks.map({ (toolShortcutLink: ToolShortcutLinkDomainModel) in
                    
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
