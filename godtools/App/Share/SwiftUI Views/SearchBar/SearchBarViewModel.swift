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
    
    var searchTextPublisher: CurrentValueSubject<String, Never>
    @Published var cancelText: String

    init(searchTextPublisher: CurrentValueSubject<String, Never>, localizationServices: LocalizationServices) {
        
        self.searchTextPublisher = searchTextPublisher
        self.cancelText = localizationServices.stringForSystemElseEnglish(key: "cancel")
    }
}
