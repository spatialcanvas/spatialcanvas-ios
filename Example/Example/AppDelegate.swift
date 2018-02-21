//
//  AppDelegate.swift
//  Example
//
//  Created by Diego Ernst on 10/10/17.
//  Copyright © 2017 SpatialCanvas. All rights reserved.
//

import UIKit
import SpatialCanvas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SpatialCanvas.shared.initialize()
        return true
    }

}

