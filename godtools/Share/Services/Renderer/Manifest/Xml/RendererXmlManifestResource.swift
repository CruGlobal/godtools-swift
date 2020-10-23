//
//  RendererXmlManifestResource.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

struct RendererXmlManifestResource: RendererManifestResourceType {
    
    let filename: String
    let src: String
    
    init(resource: XMLIndexer) {
        
        filename = resource.element?.attribute(by: "filename")?.text ?? ""
        src = resource.element?.attribute(by: "src")?.text ?? ""
    }
}
