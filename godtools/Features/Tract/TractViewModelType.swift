//
//  TractViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TractViewModelType {
    
    var resource: DownloadedResource { get }
    var navTitle: ObservableValue<String> { get }
    
    func navHomeTapped()
    func viewLoaded()
}
