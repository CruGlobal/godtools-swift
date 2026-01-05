//
//  PersonalizedToolToggleViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import Combine

class PersonalizedToolToggleViewModel: ObservableObject {

    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getPersonalizedToolToggleInterfaceStringsUseCase: GetPersonalizedToolToggleInterfaceStringsUseCase
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var selectedIndex: Int = 0
    @Published private(set) var items: [String] = []
    @Published private(set) var strings = PersonalizedToolToggleInterfaceStringsDomainModel.emptyValue
    
    private var cancellables: Set<AnyCancellable> = Set()

    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getPersonalizedToolToggleInterfaceStringsUseCase: GetPersonalizedToolToggleInterfaceStringsUseCase, dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getPersonalizedToolToggleInterfaceStringsUseCase = getPersonalizedToolToggleInterfaceStringsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getPersonalizedToolToggleInterfaceStringsUseCase.execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$strings)
        
        dashboardTabObserver
            .sink { [weak self] dashboardTab in
                guard let self = self else { return }
                let strings = self.strings
                
                switch dashboardTab {
                case .favorites:
                    self.items = []
                case .lessons:
                    self.items = [strings.personalizedText, strings.allLessonsText]
                case .tools:
                    self.items = [strings.personalizedText, strings.allToolsText]
                }
            }
            .store(in: &cancellables)
    }
}
