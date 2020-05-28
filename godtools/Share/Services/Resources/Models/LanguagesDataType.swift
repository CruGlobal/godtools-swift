//
//  LanguagesDataType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguagesDataType: Codable {
    
    associatedtype LanguagesList: Sequence
    
    var id: String { get }
    var data: LanguagesList { get }
}
