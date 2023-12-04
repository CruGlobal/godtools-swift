//
//  DownloadableLanguagesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DownloadableLanguagesViewModel: ObservableObject {
    
    private weak var flowDelegate: FlowDelegate?

    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
    }
}

// MARK: - Inputs

extension DownloadableLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromDownloadedLanguages)
    }
}


