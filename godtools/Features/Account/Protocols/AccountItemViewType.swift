//
//  AccountItemViewType.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AccountItemViewDelegate: class {
    func accountItemViewDidProcessAlertMessage(itemView: AccountItemViewType, alertMessage: AlertMessage)
}

protocol AccountItemViewType: UIView {
    var delegate: AccountItemViewDelegate? { get set }
}
