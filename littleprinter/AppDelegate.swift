//
//  AppDelegate.swift
//  littleprinter
//
//  Created by Michael Colville on 09/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Only set up manual UIWindow if we're not using SceneDelegate
        if #available(iOS 13.0, *) {
            // Handled by SceneDelegate
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            let navigationController = NavigationController()
            
            if User.shared.name == nil {
                let beginViewController = BeginViewController()
                navigationController.viewControllers = [beginViewController]
            } else {
                let printerListViewController = PrinterListViewController()
                navigationController.viewControllers = [printerListViewController]
            }
            
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let params = components.queryItems,
            let path = components.path else {
                print("Invalid URL: \(url)")
                return false
        }
        
        if (path == "/printers") {
            if let key = params.first(where: { $0.name == "add" })?.value {
                handleAddPrinterAction(key: key)
                return true
            }
        }

        return false
    }
    
    func handleAddPrinterAction(key: String) {
        print("Adding printer from url: \(key)")
        let addController = AddPrinterViewController()
        addController.printerKey = key
        if let navController = window?.rootViewController as? NavigationController {
            navController.pushViewController(addController, animated: false)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
