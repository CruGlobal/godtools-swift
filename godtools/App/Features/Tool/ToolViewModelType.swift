//
//  ToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolViewModelType: MobileContentPagesViewModel {
    
    var navBarViewModel: ObservableValue<ToolNavBarViewModelType> { get }
    var didSubscribeForRemoteSharePublishing: ObservableValue<Bool> { get }
    
    func subscribedForRemoteSharePublishing(page: Int, pagePositions: ToolPagePositions)
    func pageChanged(page: Int, pagePositions: ToolPagePositions)
    func cardChanged(page: Int, pagePositions: ToolPagePositions)
    func navHomeTapped(remoteShareIsActive: Bool)
    func navToolSettingsTapped(page: Int, selectedLanguage: LanguageModel)
    func navLanguageChanged(page: Int, pagePositions: ToolPagePositions)
}
