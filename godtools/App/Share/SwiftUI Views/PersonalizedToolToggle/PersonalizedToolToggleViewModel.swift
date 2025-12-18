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

    @Published var selectedIndex: Int = 0
    @Published private(set) var items: [String] = []
    
    private var cancellables: Set<AnyCancellable> = Set()

    init(dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>) {
        
        dashboardTabObserver
            .sink { [weak self] dashboardTab in
                
                // TODO: - create use case for getting strings
                switch dashboardTab {
                case .favorites:
                    self?.items = []
                case .lessons:
                    self?.items = ["Personalized", "All Lessons"]
                case .tools:
                    self?.items = ["Personalized", "All Tools"]
                }
            }
            .store(in: &cancellables)
    }
}
