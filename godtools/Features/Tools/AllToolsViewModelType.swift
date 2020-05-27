//
//  AllToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AllToolsViewModelType {
    
    var tools: ObservableValue<[DownloadedResource]> { get }
    
    func pageViewed()
}
