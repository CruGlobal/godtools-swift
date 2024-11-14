//
//  ResumeLessonProgressModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ResumeLessonProgressModalViewModel: ObservableObject {
    
    private let getInterfaceStringsUseCase: GetResumeLessonProgressModalInterfaceStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let startOverClosure: () -> Void
    private let continueClosure: () -> Void
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var interfaceStringsDomainModel: ResumeLessonProgressModalInterfaceStringsDomainModel = ResumeLessonProgressModalInterfaceStringsDomainModel.emptyStrings()
    
    init(getInterfaceStringsUseCase: GetResumeLessonProgressModalInterfaceStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, startOverClosure: @escaping () -> Void, continueClosure: @escaping () -> Void) {
        self.getInterfaceStringsUseCase = getInterfaceStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.startOverClosure = startOverClosure
        self.continueClosure = continueClosure
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getInterfaceStringsUseCase.getStringsPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] interfaceStrings in
                
                self?.interfaceStringsDomainModel = interfaceStrings
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Inputs
    
    func startOverButtonTapped() {
        startOverClosure()
    }
    
    func continueButtonTapped() {
        continueClosure()
    }
}
