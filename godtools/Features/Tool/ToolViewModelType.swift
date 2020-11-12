//
//  ToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolViewModelType {
    
    var navBarViewModel: ToolNavBarViewModel { get }
    var selectedToolLanguage: ObservableValue<TractLanguage> { get }
    var currentPage: ObservableValue<AnimatableValue<Int>> { get }
    var isRightToLeftLanguage: Bool { get }
    var remoteShareIsActive: ObservableValue<Bool> { get }
    var numberOfToolPages: ObservableValue<Int> { get }
    
    func navHomeTapped()
    func shareTapped()
    func primaryLanguageTapped()
    func parallelLanguagedTapped()
    func viewLoaded()
    func toolPageWillAppear(page: Int) -> ToolPageViewModel?
    func toolPageDidChange(page: Int)
    func toolPageDidAppear(page: Int)
    //func tractPageCardStateChanged(cardState: TractCardProperties.CardState)
    //func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?)
    //func getTractPageItem(page: Int) -> TractPageItem
}
