//
//  SceneDelegate.swift
//  TO
//
//  Created by RX Group on 15.02.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var noIinternet:NoInternetView!
    var reachability = Reachability()!


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        LocationManager.shared.updateLocation()
        window?.overrideUserInterfaceStyle = .light
        if let data = UserDefaults.standard.value(forKey:"cards") as? Data {
            arrayCards = try! PropertyListDecoder().decode(Array<SavedCard>.self, from: data)
        }
        
        reachability.whenReachable = { reachability in
            self.noIinternet.isHidden = true
        }
        reachability.whenUnreachable = { _ in
            self.noIinternet.frame = self.window!.frame
            self.window!.bringSubviewToFront(self.noIinternet)
            self.noIinternet.isHidden = false
        }
        

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        noIinternet = NoInternetView(frame: window!.bounds)
        window?.addSubview(noIinternet)
        noIinternet.isHidden = true
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

