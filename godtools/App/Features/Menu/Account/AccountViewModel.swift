//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountViewModel: AccountViewModelType {
    
    private let oktaUserAuthentication: OktaUserAuthentication
    private let analytics: AnalyticsContainer
        
    let globalAnalyticsService: GlobalAnalyticsService
    let localizationServices: LocalizationServices
    let navTitle: String
    let profileName: ObservableValue<AnimatableValue<String>> = ObservableValue(value: AnimatableValue(value: "", animated: false))
    let isLoadingProfile: ObservableValue<Bool> = ObservableValue(value: false)
    let accountItems: ObservableValue<[AccountItem]> = ObservableValue(value: [])
    let currentAccountItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(oktaUserAuthentication: OktaUserAuthentication, globalAnalyticsService: GlobalAnalyticsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.oktaUserAuthentication = oktaUserAuthentication
        self.globalAnalyticsService = globalAnalyticsService
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        navTitle = localizationServices.stringForMainBundle(key: "account.navTitle")
        
        reloadUserProfile()
        
        reloadAccountItems()
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
    
    private func reloadUserProfile() {
        
        isLoadingProfile.accept(value: true)
        
        oktaUserAuthentication.getAuthenticatedUser { [weak self] (result: Result<OktaAuthUserModel, Error>) in
            DispatchQueue.main.async { [weak self] in
                
                self?.isLoadingProfile.accept(value: false)
                                
                switch result {
                
                case .success(let authUser):
                    
                    if let firstName = authUser.firstName, let lastName = authUser.lastName {
                        let profileNameValue: String = firstName + " " + lastName
                        self?.profileName.accept(value: AnimatableValue(value: profileNameValue, animated: true))
                    }
                
                case .failure(let error):
                    break
                }
            }
        }
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getAnalyticsScreenName(page: page), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
