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
import GodToolsShared

@MainActor class AccountViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase
    private let getUserActivityUseCase: GetUserActivityUseCase
    private let viewGlobalActivityThisWeekUseCase: ViewGlobalActivityThisWeekUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let getAccountStringsUseCase: GetAccountStringsUseCase
    private let getGlobalActivityEnabledUseCase: GetGlobalActivityEnabledUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var didPullToRefresh: Void = ()
    
    @Published private(set) var strings = AccountStringsDomainModel.emptyValue
    @Published private(set) var isLoadingProfile: Bool = true
    @Published private(set) var isLoadingGlobalActivityThisWeek: Bool = true
    @Published private(set) var userDetails = UserAccountDetailsDomainModel.emptyValue
    @Published private(set) var badges = [UserActivityBadgeDomainModel]()
    @Published private(set) var globalActivitiesThisWeek: [GlobalActivityThisWeekDomainModel] = Array()
    @Published private(set) var stats = [UserActivityStatDomainModel]()
    @Published private(set) var globalActivityIsEnabled: Bool = false
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase, getUserActivityUseCase: GetUserActivityUseCase, viewGlobalActivityThisWeekUseCase: ViewGlobalActivityThisWeekUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, getAccountStringsUseCase: GetAccountStringsUseCase, getGlobalActivityEnabledUseCase: GetGlobalActivityEnabledUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getUserAccountDetailsUseCase = getUserAccountDetailsUseCase
        self.viewGlobalActivityThisWeekUseCase = viewGlobalActivityThisWeekUseCase
        self.getUserActivityUseCase = getUserActivityUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.getAccountStringsUseCase = getAccountStringsUseCase
        self.getGlobalActivityEnabledUseCase = getGlobalActivityEnabledUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getAccountStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: AccountStringsDomainModel) in
                       
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getUserAccountDetailsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (userDetails: UserAccountDetailsDomainModel) in
                
                self?.isLoadingProfile = false
                self?.userDetails = userDetails
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewGlobalActivityThisWeekUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewGlobalActivityThisWeekDomainModel) in
                
                self?.isLoadingGlobalActivityThisWeek = false
                self?.globalActivitiesThisWeek = domainModel.activityItems
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $didPullToRefresh
        )
        .map { (appLanguage: AppLanguageDomainModel, didPullToRefresh: Void) in
            
            getUserActivityUseCase
                .execute(appLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (userActivity: UserActivityDomainModel) in
            
            self?.badges = userActivity.badges
            self?.stats = userActivity.stats
        })
        .store(in: &cancellables)
        
        getGlobalActivityEnabledUseCase
            .getIsEnabledPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$globalActivityIsEnabled)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func trackSectionViewedAnalytics(screenName: String) {
                 
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: screenName,
            siteSection: "account",
            siteSubSection: "",
            appLanguage: nil,
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
        
        didPullToRefresh = ()
    }
    
    func activityViewed() {
        
        trackSectionViewedAnalytics(screenName: AnalyticsScreenNames.shared.ACCOUNT_ACTIVITY)
    }
    
    func globalActivityViewed() {
        
        trackSectionViewedAnalytics(screenName: AnalyticsScreenNames.shared.ACCOUNT_GLOBAL_ACTIVITY)
    }
    
    func getGlobalActivityAnalyticsItemViewModel(index: Int) -> AccountGlobalActivityAnalyticsItemViewModel {
        
        return AccountGlobalActivityAnalyticsItemViewModel(
            globalActivity: globalActivitiesThisWeek[index]
        )
    }
}
