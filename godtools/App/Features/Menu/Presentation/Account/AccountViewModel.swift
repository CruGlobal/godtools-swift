//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import GodToolsToolParser

class AccountViewModel: ObservableObject {
    
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase
    private let getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase
    private let getUserActivityUseCase: GetUserActivityUseCase
    private let getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase
    private let analytics: AnalyticsContainer
    
    private var globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String
    @Published var isLoadingProfile: Bool = true
    @Published var isLoadingGlobalActivityThisWeek: Bool = true
    @Published var profileName: String = ""
    @Published var joinedOnText: String = ""
    @Published var activityButtonTitle: String
    @Published var globalActivityButtonTitle: String
    @Published var globalActivityTitle: String
    @Published var numberOfGlobalActivityThisWeekItems: Int = 0
    @Published var badges = [UserActivityBadgeDomainModel]()
        
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase, getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase, getUserActivityUseCase: GetUserActivityUseCase, getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getUserAccountDetailsUseCase = getUserAccountDetailsUseCase
        self.getUserAccountProfileNameUseCase = getUserAccountProfileNameUseCase
        self.getGlobalActivityThisWeekUseCase = getGlobalActivityThisWeekUseCase
        self.getUserActivityUseCase = getUserActivityUseCase
        self.analytics = analytics
        
        navTitle = localizationServices.stringForMainBundle(key: "account.navTitle")
        activityButtonTitle = localizationServices.stringForMainBundle(key: "account.activity.title")
        globalActivityButtonTitle = localizationServices.stringForMainBundle(key: "account.globalActivity.title")
        
        let localizedGlobalActivityTitle: String = localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.header.title")
        let todaysDate: Date = Date()
        let todaysYearComponents: DateComponents = Calendar.current.dateComponents([.year], from: todaysDate)
                
        if let year = todaysYearComponents.year {
            globalActivityTitle = "\(year) \(localizedGlobalActivityTitle)"
        }
        else {
            globalActivityTitle = localizedGlobalActivityTitle
        }
                
        getUserAccountProfileNameUseCase.getProfileNamePublisher()
            .receiveOnMain()
            .sink { [weak self] (profileNameDomainModel: AccountProfileNameDomainModel) in
                
                self?.isLoadingProfile = false
                self?.profileName = profileNameDomainModel.value
            }
            .store(in: &cancellables)
        
        getUserAccountDetailsUseCase.getUserAccountDetailsPublisher()
            .receiveOnMain()
            .sink { [weak self] userDetails in
                
                self?.joinedOnText = userDetails.joinedOnString
            }
            .store(in: &cancellables)
        
        getGlobalActivityThisWeekUseCase.getGlobalActivityPublisher()
            .receiveOnMain()
            .sink { [weak self] (globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel]) in
                
                self?.isLoadingGlobalActivityThisWeek = false
                self?.globalActivityThisWeekDomainModels = globalActivityThisWeekDomainModels
                self?.numberOfGlobalActivityThisWeekItems = globalActivityThisWeekDomainModels.count
            }
            .store(in: &cancellables)
        
        getUserActivityUseCase.getUserActivityPublisher()
            .receiveOnMain()
            .sink { _ in
                
            } receiveValue: { userActivity in
                
                self.updateUserActivityValues(userActivity: userActivity)
            }
            .store(in: &cancellables)

    }
    
    private func updateUserActivityValues(userActivity: UserActivityDomainModel) {
        
        self.badges = userActivity.badges
        
    }
    
    private func trackSectionViewedAnalytics(screenName: String) {
                        
        let trackScreen = TrackScreenModel(
            screenName: screenName,
            siteSection: "account",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
}

// MARK: - Inputs

extension AccountViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromMyAccount)
    }
    
    func activityViewed() {
        
        trackSectionViewedAnalytics(screenName: AnalyticsScreenNames.shared.ACCOUNT_ACTIVITY)
    }
    
    func globalActivityViewed() {
        
        trackSectionViewedAnalytics(screenName: AnalyticsScreenNames.shared.ACCOUNT_GLOBAL_ACTIVITY)
    }
    
    func getGlobalActivityAnalyticsItem(index: Int) -> AccountGlobalActivityAnalyticsItemViewModel {
        
        return AccountGlobalActivityAnalyticsItemViewModel(globalActivity: globalActivityThisWeekDomainModels[index])
    }
}
