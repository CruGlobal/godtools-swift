//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

class AccountViewModel: AccountViewModelType {
    
    private let analytics: AnalyticsContainer
        
    let globalActivityServices: GlobalActivityServicesType
    let navTitle: String
    let profileName: ObservableValue<(name: String, animated: Bool)> = ObservableValue(value: (name: "", animated: false))
    let isLoadingProfile: ObservableValue<Bool> = ObservableValue(value: false)
    let accountItems: ObservableValue<[AccountItem]> = ObservableValue(value: [])
    let currentAccountItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(loginClient: TheKeyOAuthClient, globalActivityServices: GlobalActivityServicesType, analytics: AnalyticsContainer) {
        
        self.globalActivityServices = globalActivityServices
        self.analytics = analytics
        
        navTitle = NSLocalizedString("account.navTitle", comment: "")
        
        isLoadingProfile.accept(value: true)
        loginClient.fetchAttributes { [weak self] (attributes: [String: String]?, error: Error?) in
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingProfile.accept(value: false)
                if let attributes = attributes, let firstName = attributes["firstName"], let lastName = attributes["lastName"] {
                    self?.profileName.accept(value: (name: firstName + " " + lastName, animated: true))
                }
            }
        }
        
        let items: [AccountItem] = [
            AccountItem(
                itemId: .activity,
                title: NSLocalizedString("account.activity.title", comment: ""),
                analyticsScreenName: "Global Dashboard"
            )
        ]
        
        accountItems.accept(value: items)
        
        accountPageDidAppear(page: 0)
    }
    
    func settingsTapped() {
        print("TODO: AccountViewModel Implement settings.")
    }
    
    func accountPageDidAppear(page: Int) {
        
        let accountItem: AccountItem = accountItems.value[page]
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: accountItem.analyticsScreenName,
            siteSection: "",
            siteSubSection: ""
        )
    }
}
