//
//  DisableGoogleTagManagerLogging.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class DisableGoogleTagManagerLogging: Sendable {
    
    static func hideGTMLogsInfo() {
        let tagClass: AnyClass? = NSClassFromString("TAGLogger")

        let originalSelector = NSSelectorFromString("info:")
        let detourSelector = #selector(DisableGoogleTagManagerLogging.detour_info(message:))

        guard let originalMethod = class_getClassMethod(tagClass, originalSelector),
            let detourMethod = class_getClassMethod(DisableGoogleTagManagerLogging.self, detourSelector) else { return }

        class_addMethod(tagClass, detourSelector,
                        method_getImplementation(detourMethod), method_getTypeEncoding(detourMethod))
        method_exchangeImplementations(originalMethod, detourMethod)
    }

    static func hideGTMLogsWarning() {
        let tagClass: AnyClass? = NSClassFromString("TAGLogger")

        let originalSelector = NSSelectorFromString("warning:")
        let detourSelector = #selector(DisableGoogleTagManagerLogging.detour_warning(message:))

        guard let originalMethod = class_getClassMethod(tagClass, originalSelector),
            let detourMethod = class_getClassMethod(DisableGoogleTagManagerLogging.self, detourSelector) else { return }

        class_addMethod(tagClass, detourSelector,
                        method_getImplementation(detourMethod), method_getTypeEncoding(detourMethod))
        method_exchangeImplementations(originalMethod, detourMethod)
    }

    @objc
    static func detour_warning(message: String) {
        return
    }
    @objc
    static func detour_info(message: String) {
        return
    }
}
