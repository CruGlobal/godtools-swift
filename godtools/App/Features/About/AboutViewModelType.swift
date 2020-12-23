//
//  AboutViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AboutViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var aboutTexts: ObservableValue<[AboutTextModel]> { get }
    
    func pageViewed()
}
