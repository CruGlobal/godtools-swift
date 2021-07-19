//
//  MobileContentXmlManifestTip.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class MobileContentXmlManifestTip: MobileContentManifestTipType {
    
    let id: String
    let src: String
    
    required init(tip: XMLIndexer) {
        
        id = tip.element?.attribute(by: "id")?.text ?? ""
        src = tip.element?.attribute(by: "src")?.text ?? ""
    }
}
