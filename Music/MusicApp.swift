import SwiftUI

@main
struct MusicApp: App {
    init() {
        UIToolbar.appearance().barTintColor = UIColor(DarkGray)
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        let AppearanceColor = UINavigationBarAppearance()
        AppearanceColor.configureWithOpaqueBackground()
        AppearanceColor.backgroundColor = UIColor(DarkGray)
        UINavigationBar.appearance().standardAppearance = AppearanceColor
        UINavigationBar.appearance().compactAppearance = AppearanceColor
        UINavigationBar.appearance().scrollEdgeAppearance = AppearanceColor
        UINavigationBar.appearance().standardAppearance.shadowColor = UIColor(DarkGray)
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().tintColor = .white
        UIScrollView.appearance().scrollsToTop = false
        UISearchBar.appearance().tintColor = .white
        UISearchBar.appearance().barTintColor = UIColor(DarkGray)
        UISearchBar.appearance().setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.white)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
