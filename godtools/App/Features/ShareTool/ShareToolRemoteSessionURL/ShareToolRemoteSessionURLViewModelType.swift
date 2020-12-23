//
//  ShareToolRemoteSessionURLViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareToolRemoteSessionURLViewModelType {
    
    var shareMessage: String { get }
    
    func pageViewed()
}
