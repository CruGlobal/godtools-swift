//
//  ToolSettingsShareablesViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser

class ToolSettingsShareablesViewModel: ObservableObject {
    
    private let shareables: [Shareable]
    
    @Published var numberOfItems: Int = 3
    
    required init(shareables: [Shareable]) {
        
        self.shareables = shareables
        self.numberOfItems = shareables.count
    }
}
