//
//  ShareGodToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor class ShareGodToolsViewModel: ObservableObject {
    
    private let strings: ShareGodToolsStringsDomainModel
    
    @Published var shareMessage: String = ""
    
    init(strings: ShareGodToolsStringsDomainModel) {
        
        self.strings = strings
        
        shareMessage = strings.shareMessage
    }
}
