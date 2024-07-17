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
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase
    private let getUserActivityUseCase: GetUserActivityUseCase
    private let viewGlobalActivityThisWeekUseCase: ViewGlobalActivityThisWeekUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let viewAccountUseCase: ViewAccountUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var didPullToRefresh: Void = ()
    
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
    @Published var globalActivitiesThisWeek: [GlobalActivityThisWeekDomainModel] = Array()
    @Published var stats = [UserActivityStatDomainModel]()
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase, getUserActivityUseCase: GetUserActivityUseCase, viewGlobalActivityThisWeekUseCase: ViewGlobalActivityThisWeekUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, viewAccountUseCase: ViewAccountUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getUserAccountDetailsUseCase = getUserAccountDetailsUseCase
        self.viewGlobalActivityThisWeekUseCase = viewGlobalActivityThisWeekUseCase
        self.getUserActivityUseCase = getUserActivityUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.viewAccountUseCase = viewAccountUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewAccountUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewAccountDomainModel in
                
                let interfaceStrings = viewAccountDomainModel.interfaceStrings
                
                self?.navTitle = interfaceStrings.navTitle
                self?.activityButtonTitle = interfaceStrings.activityButtonTitle
                self?.myActivitySectionTitle = interfaceStrings.myActivitySectionTitle
                self?.badgesSectionTitle = interfaceStrings.badgesSectionTitle
                self?.globalActivityButtonTitle = interfaceStrings.globalActivityButtonTitle
                self?.globalActivityTitle = interfaceStrings.globalAnalyticsTitle
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getUserAccountDetailsUseCase
                    .getUserAccountDetailsPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userDetails: UserAccountDetailsDomainModel) in
                
                self?.isLoadingProfile = false
                
                self?.profileName = userDetails.name
                self?.joinedOnText = userDetails.joinedOnString
            }
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
                .getUserActivityPublisher(appLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (userActivity: UserActivityDomainModel) in
                
            self?.badges = userActivity.badges
            self?.stats = userActivity.stats
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
