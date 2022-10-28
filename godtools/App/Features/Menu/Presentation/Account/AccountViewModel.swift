//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class AccountViewModel: AccountViewModelType {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase
    private let analytics: AnalyticsContainer
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    let globalAnalyticsService: GlobalAnalyticsService
    let localizationServices: LocalizationServices
    let navTitle: String
    let profileName: ObservableValue<AnimatableValue<String>> = ObservableValue(value: AnimatableValue(value: "", animated: false))
    let isLoadingProfile: ObservableValue<Bool> = ObservableValue(value: true)
    let accountItems: ObservableValue<[AccountItem]> = ObservableValue(value: [])
    let currentAccountItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    
    init(globalAnalyticsService: GlobalAnalyticsService, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase, analytics: AnalyticsContainer) {
        
        self.globalAnalyticsService = globalAnalyticsService
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getUserAccountProfileNameUseCase = getUserAccountProfileNameUseCase
        self.analytics = analytics
        
        navTitle = localizationServices.stringForMainBundle(key: "account.navTitle")
                
        reloadAccountItems()
        
        getUserAccountProfileNameUseCase.getProfileNamePublisher()
            .receiveOnMain()
            .sink { [weak self] (profileNameDomainModel: AccountProfileNameDomainModel) in
                self?.isLoadingProfile.accept(value: false)
                self?.profileName.accept(value: AnimatableValue(value: profileNameDomainModel.value, animated: true))
            }
            .store(in: &cancellables)
    }
    
    private func getAnalyticsScreenName (page: Int) -> String {
        let accountItem: AccountItem = accountItems.value[page]
        
        return accountItem.analyticsScreenName
    }
    
    private var analyticsSiteSection: String {
        return "account"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func reloadAccountItems() {
        
        let items: [AccountItem] = [
            AccountItem(
                itemId: .activity,
                title: localizationServices.stringForMainBundle(key: "account.activity.title"),
                analyticsScreenName: "Global Dashboard"
            )
        ]
        
        accountItems.accept(value: items)
    }
    
    func settingsTapped() {
        print("TODO: AccountViewModel Implement settings.")
    }

    func accountPageDidAppear(page: Int) {
        
        let trackScreen = TrackScreenModel(
            screenName: getAnalyticsScreenName(page: page),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
}
