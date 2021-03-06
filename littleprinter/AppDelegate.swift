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
        
        // uncomment for font list.
        // print(UIFont.familyNames.sorted());
        
        return true
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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

