//
//  CopyrightInfoWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct CopyrightInfoWebContent: WebContentType {
    
    let navTitle: String = NSLocalizedString("copyright_info", comment: "")
    let url: URL? = URL(string: "http://www.godtoolsapp.com/copyright")
    let analyticsScreenName: String = "Copyright Info"
}
