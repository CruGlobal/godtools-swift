//
//  ToolCardProvider.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCardProvider: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    var maxNumberCardsToShow: Int? = nil
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
    
    // MARK: - Public
    
    func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        assertionFailure("This method should be overriden in the subclass")
        return BaseToolCardViewModel()
    }
    
    func toolTapped(resource: ResourceModel) {}
}
