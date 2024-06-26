//
//  SearchBarViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchBarViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published var cancelText: String = ""
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                
                viewSearchBarUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                
                let interfaceStrings = domainModel.interfaceStrings
                
                self?.cancelText = interfaceStrings.cancel
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
