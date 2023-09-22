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
    private let getInterfaceStringUseCase: GetInterfaceStringUseCase
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
        
    init(flowDelegate: FlowDelegate, getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase, getUserActivityUseCase: GetUserActivityUseCase, getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase, getInterfaceStringUseCase: GetInterfaceStringUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getUserAccountDetailsUseCase = getUserAccountDetailsUseCase
        self.getGlobalActivityThisWeekUseCase = getGlobalActivityThisWeekUseCase
        self.getUserActivityUseCase = getUserActivityUseCase
        self.getInterfaceStringUseCase = getInterfaceStringUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.navTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.navTitle, on: self)
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.activityButtonTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.activityButtonTitle, on: self)
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.activitySectionTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.myActivitySectionTitle, on: self)
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.badgesSectionTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.badgesSectionTitle, on: self)
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.globalActivityButtonTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: \.globalActivityButtonTitle, on: self)
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: MenuStringKeys.Account.globalAnalyticsTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (localizedGlobalActivityTitle: String) in
                
                let todaysDate: Date = Date()
                let todaysYearComponents: DateComponents = Calendar.current.dateComponents([.year], from: todaysDate)
                        
                if let year = todaysYearComponents.year {
                    self?.globalActivityTitle = "\(year) \(localizedGlobalActivityTitle)"
                }
                else {
                    self?.globalActivityTitle = localizedGlobalActivityTitle
                }
            })
            .store(in: &cancellables)
                
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
