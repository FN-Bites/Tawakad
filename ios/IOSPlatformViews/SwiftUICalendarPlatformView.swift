import Flutter
import UIKit
import SwiftUI

class SwiftUICalendarPlatformView: NSObject, FlutterPlatformView {
    private let hostingController: UIHostingController<CalendarView>

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        hostingController = UIHostingController(rootView: CalendarView())
        super.init()
        hostingController.view.frame = frame
        hostingController.view.backgroundColor = UIColor.clear
    }

    func view() -> UIView {
        hostingController.view
    }
}