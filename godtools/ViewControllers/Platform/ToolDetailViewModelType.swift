//
//  ToolDetailViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolDetailViewModelType {
    
    var resource: DownloadedResource { get }
    var hidesOpenToolButton: Bool { get }
    var aboutDetails: String { get }
    var languageDetails: String { get }
    
    func urlTapped(url: URL)
}
