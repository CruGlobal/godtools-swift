//
//  main.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestsAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
