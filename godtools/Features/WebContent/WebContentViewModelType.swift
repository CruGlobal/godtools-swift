//
//  WebContentViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebContentViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var url: ObservableValue<URL?> { get }
    
    func pageViewed()
}
