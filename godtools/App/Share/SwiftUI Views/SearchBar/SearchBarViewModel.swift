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
    
    let searchTextPublisher: CurrentValueSubject<String, Never>
    @Published var cancelText: String = ""

    init(searchTextPublisher: CurrentValueSubject<String, Never>, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
        
        self.searchTextPublisher = searchTextPublisher
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: "cancel")
            .receive(on: DispatchQueue.main)
            .assign(to: &$cancelText)
    }
}
