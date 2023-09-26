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
    
    private let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase
    private let getUserActivityUseCase: GetUserActivityUseCase
    private let getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    private var getActivityCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String = ""
    @Published var isLoadingProfile: Bool = true
    @Published var isLoadingGlobalActivityThisWeek: Bool = true
    @Published var profileName: String = ""
    @Published var joinedOnText: String = ""
    @Published var activityButtonTitle: String = ""
    @Published var myActivitySectionTitle: String = ""
    @Published var badges = [UserActivityBadgeDomainModel]()
    @Published var badgesSectionTitle: String = ""
    @Published var globalActivityButtonTitle: String = ""
    @Published var globalActivityTitle: String = ""
    @Published var numberOfGlobalActivityThisWeekItems: Int = 0
    @Published var stats = [UserActivityStatDomainModel]()
        
    init(flowDelegate: FlowDelegate, getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase, getUserActivityUseCase: GetUserActivityUseCase, getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getUserAccountDetailsUseCase = getUserAccountDetailsUseCase
        self.getGlobalActivityThisWeekUseCase = getGlobalActivityThisWeekUseCase
        self.getUserActivityUseCase = getUserActivityUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.navTitle.rawValue)
        activityButtonTitle = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.activityButtonTitle.rawValue)
        myActivitySectionTitle = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.activitySectionTitle.rawValue)
        badgesSectionTitle = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.badgesSectionTitle.rawValue)
        globalActivityButtonTitle = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.globalActivityButtonTitle.rawValue)
        
        let localizedGlobalActivityTitle: String = getInterfaceStringInAppLanguageUseCase.getString(id: MenuStringKeys.Account.globalAnalyticsTitle.rawValue)
        let todaysDate: Date = Date()
        let todaysYearComponents: DateComponents = Calendar.current.dateComponents([.year], from: todaysDate)
                
        if let year = todaysYearComponents.year {
            globalActivityTitle = "\(year) \(localizedGlobalActivityTitle)"
        }
        else {
            globalActivityTitle = localizedGlobalActivityTitle
        }
                
        getUserAccountDetailsUseCase.getUserAccountDetailsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userDetails: UserAccountDetailsDomainModel) in
                
                self?.isLoadingProfile = false
                
                self?.profileName = userDetails.name
                self?.joinedOnText = userDetails.joinedOnString
            }
            .store(in: &cancellables)
        
        getGlobalActivityThisWeekUseCase.getGlobalActivityPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel]) in
                
                self?.isLoadingGlobalActivityThisWeek = false
                self?.globalActivityThisWeekDomainModels = globalActivityThisWeekDomainModels
                self?.numberOfGlobalActivityThisWeekItems = globalActivityThisWeekDomainModels.count
            }
            .store(in: &cancellables)
        
        refreshUserActivity()
    }
    
    private func refreshUserActivity() {
        
        getActivityCancellable = getUserActivityUseCase.getUserActivityPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { userActivity in
                
                self.updateUserActivityValues(userActivity: userActivity)
            }
    }
    
    private func updateUserActivityValues(userActivity: UserActivityDomainModel) {
        
        self.badges = userActivity.badges
        self.stats = userActivity.stats
    }
    
    private func trackSectionViewedAnalytics(screenName: String) {
                 
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: screenName,
            siteSection: "account",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}

// MARK: - Inputs

extension AccountViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromActivity)
    }
    
    func pullToRefresh() {
        
        refreshUserActivity()
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
