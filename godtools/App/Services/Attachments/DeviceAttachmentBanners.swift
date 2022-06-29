//
//  DeviceAttachmentBanners.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// TODO: Remove in place of ResourceBannerImageRepository. ~Levi
@available(*, deprecated)
class DeviceAttachmentBanners {
    
    typealias ResourceId = String
    
    private let deviceAttachments: [ResourceId: SHA256FileLocation]
    private let bundle: Bundle = Bundle.main
    
    required init() {
        
        deviceAttachments = [
            "1": SHA256FileLocation(sha256: "a6765002e46cea44dc6245bcb842ce01a0134c147c47cf108134a4c4d1a5c129", pathExtension: "jpg"),
            "2": SHA256FileLocation(sha256: "2626c83091f11eb08c2bded5d4a237fa986fe3a318d1fb14933906021a7493a7", pathExtension: "jpg"),
            "3": SHA256FileLocation(sha256: "86c8e65bddaa4b889e572aa89714ee846f27294abc62b69d291b52ea1cc05144", pathExtension: "jpg"),
            "4": SHA256FileLocation(sha256: "36ec96dc7e53cf2387e448a34740c599fe6fb3c51a597fc49667664ca2828e52", pathExtension: "jpg"),
            "5": SHA256FileLocation(sha256: "1958f6ba22b659adfc7eb43dcfac7cc5cfe192df45437355aa99a8752192ed92", pathExtension: "jpg"),
            "6": SHA256FileLocation(sha256: "e5dd66976d53a69bbd12867079750e14732c5112a254022c038738f7f12953a8", pathExtension: "png"),
            "7": SHA256FileLocation(sha256: "bae08d104b5ad1e9d7f97a25a88800adbce94cf36c508deaf3a2067f45919a36", pathExtension: "png"),
            "8": SHA256FileLocation(sha256: "e999c849242ba4abf20560274f92dd6c77631992d10db0eca5515e80ffb431c6", pathExtension: "jpg"),
            "9": SHA256FileLocation(sha256: "057e056ad4c27921d537c74f8e59396214330a1ed084efcb5d265d01cb7f0d4e", pathExtension: "jpg"),
            "10": SHA256FileLocation(sha256: "85ee4662cc5e6d7794928aee69a73bee6714e7c76d131040a8e0352e9c529588", pathExtension: "jpg")
        ]
    }
    
    func getDeviceBanner(resourceId: String) -> UIImage? {
        
        guard let location = deviceAttachments[resourceId] else {
            return nil
        }
        
        guard let path = bundle.path(forResource: location.sha256, ofType: location.pathExtension) else {
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        return image
    }
}
