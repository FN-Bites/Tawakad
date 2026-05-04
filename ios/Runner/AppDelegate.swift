import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let registrar = self.registrar(forPlugin: "CalendarView") {
            registrar.register(
                CalendarViewFactory(messenger: registrar.messenger()),
                withId: "calendar-view"
            )
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
