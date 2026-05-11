import Flutter
import UIKit

class SwiftUICalendarFactory: NSObject, FlutterPlatformViewFactory {

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return SwiftUICalendarPlatformView(frame: frame, viewId: viewId, args: args)
    }
}
