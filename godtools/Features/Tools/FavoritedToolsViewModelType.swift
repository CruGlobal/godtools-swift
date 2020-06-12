//
//  FavoritedToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FavoritedToolsViewModelType: ToolsViewModelType {
    
    var findToolsTitle: String { get }
    var hidesFindToolsView: ObservableValue<Bool> { get }
    
    func pageViewed()
}
