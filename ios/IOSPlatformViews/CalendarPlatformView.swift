import Flutter
import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalendarPlatformView: NSObject, FlutterPlatformView {
    private var calendarVC: CalendarViewController
    private var containerView: UIView

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
        containerView = UIView(frame: frame)
        calendarVC = CalendarViewController()
        super.init()

        // Embed the CalendarKit view controller
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.addChild(calendarVC)
            calendarVC.view.frame = containerView.bounds
            calendarVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(calendarVC.view)
            calendarVC.didMove(toParent: rootVC)
        }
    }

    func view() -> UIView {
        return containerView
    }
}
