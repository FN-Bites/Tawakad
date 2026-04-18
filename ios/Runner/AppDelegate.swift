import Flutter
import UIKit
import Firebase
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let registrar = self.registrar(forPlugin: "SwiftUICalendarFactory")!
        let factory = SwiftUICalendarFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "ios-calendar-view")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
} 