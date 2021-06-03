//
//  FirebaseAnalyticsType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FirebaseAnalyticsType: MobileContentAnalyticsSystem {
    func configure()
    func trackScreenView(trackScreen: TrackScreenModel)
    func trackAction(trackAction: TrackActionModel)
    func trackExitLink(exitLink: ExitLinkModel)
    func fetchAttributesThenSetUserId()
}
