//
//  AllToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AllToolsViewModelType: ToolsViewModelType {
    
    var message: ObservableValue<String> { get }
    var isLoading: ObservableValue<Bool> { get }
    
    func pageViewed()
}
