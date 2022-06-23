//
//  ToolCardsCarouselViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCardsCarouselViewModel: NSObject, ObservableObject {
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
    
    // MARK: - Public
    
    func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        assertionFailure("This method should be overriden in the subclass")
        return MockToolCardViewModel()
    }
}
