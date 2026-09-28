import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = NavigationController()
        
        if User.shared.name == nil {
            let beginViewController = BeginViewController()
            navigationController.viewControllers = [beginViewController]
        } else {
            let printerListViewController = PrinterListViewController()
            navigationController.viewControllers = [printerListViewController]
        }
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle URL from connectionOptions if needed
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }
    
    private func handleURL(_ url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let params = components.queryItems,
              let path = components.path else {
            print("Invalid URL: \(url)")
            return
        }
        
        if (path == "/printers") {
            if let key = params.first(where: { $0.name == "add" })?.value {
                handleAddPrinterAction(key: key)
            }
        }
    }
    
    private func handleAddPrinterAction(key: String) {
        print("Adding printer from url: \(key)")
        let addController = AddPrinterViewController()
        addController.printerKey = key
        if let navController = window?.rootViewController as? NavigationController {
            navController.pushViewController(addController, animated: false)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
