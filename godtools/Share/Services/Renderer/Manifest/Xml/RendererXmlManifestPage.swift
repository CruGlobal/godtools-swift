//
//  RendererXmlManifestPage.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

struct RendererXmlManifestPage: RendererManifestPageType {
    
    let filename: String
    let src: String
    
    init(page: XMLIndexer) {
        
        filename = page.element?.attribute(by: "filename")?.text ?? ""
        src = page.element?.attribute(by: "src")?.text ?? ""
    }
}
