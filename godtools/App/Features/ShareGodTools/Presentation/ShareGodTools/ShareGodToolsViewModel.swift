//
//  ShareGodToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ShareGodToolsViewModel: ObservableObject {
    
    private let viewShareGodToolsDomainModel: ViewShareGodToolsDomainModel
    
    @Published var shareMessage: String = ""
    
    init(viewShareGodToolsDomainModel: ViewShareGodToolsDomainModel) {
        
        self.viewShareGodToolsDomainModel = viewShareGodToolsDomainModel
        
        shareMessage = viewShareGodToolsDomainModel.interfaceStrings.shareMessage
    }
}
