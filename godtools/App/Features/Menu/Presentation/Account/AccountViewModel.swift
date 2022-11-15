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

class AccountViewModel: ObservableObject {
    
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase
    private let getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase
    private let analytics: AnalyticsContainer
    
    private var globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String
    @Published var isLoadingProfile: Bool = true
    @Published var profileName: String = ""
    @Published var activityButtonTitle: String
    @Published var globalActivityButtonTitle: String
    @Published var globalActivityTitle: String
    @Published var numberOfGlobalActivityThisWeekItems: Int = 0
        
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getUserAccountProfileNameUseCase: GetUserAccountProfileNameUseCase, getGlobalActivityThisWeekUseCase: GetGlobalActivityThisWeekUseCase, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getUserAccountProfileNameUseCase = getUserAccountProfileNameUseCase
        self.getGlobalActivityThisWeekUseCase = getGlobalActivityThisWeekUseCase
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
        
        getGlobalActivityThisWeekUseCase.getGlobalActivityPublisher()
            .receiveOnMain()
            .sink { [weak self] (globalActivityThisWeekDomainModels: [GlobalActivityThisWeekDomainModel]) in
                
                self?.globalActivityThisWeekDomainModels = globalActivityThisWeekDomainModels
                
                self?.numberOfGlobalActivityThisWeekItems = globalActivityThisWeekDomainModels.count
            }
            .store(in: &cancellables)
    }
    
    private func trackSectionViewedAnalytics(sectionName: String) {
        
        let trackScreen = TrackScreenModel(
            screenName: sectionName,
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
    
    func activityTapped() {
        
        // TODO: Ensure this is the correct page name for when Activity section is viewed. GT-1861 ~Levi
        trackSectionViewedAnalytics(sectionName: "Activity")
    }
    
    func globalActivityTapped() {
        
        trackSectionViewedAnalytics(sectionName: "Global Dashboard")
    }
    
    func globalActivityAnalyticsItemWillAppear(index: Int) -> AccountGlobalActivityAnalyticsItemViewModel {
        
        return AccountGlobalActivityAnalyticsItemViewModel(globalActivity: globalActivityThisWeekDomainModels[index])
    }
}
