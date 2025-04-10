//
//  LessonSwipeTutorialViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonSwipeTutorialViewModel: ObservableObject {
    
    private weak var flowDelegate: FlowDelegate?

    private var cancellables: Set<AnyCancellable> = Set()

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue

    
    init(flowDelegate: FlowDelegate) {
        self.flowDelegate = flowDelegate
    }
    
    // MARK: - Input
    
    func dismissTutorial() {
        flowDelegate?.navigate(step: .closeLessonSwipeTutorial)
    }
}
