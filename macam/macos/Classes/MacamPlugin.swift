import Cocoa
import FlutterMacOS
import WebKit

public class MacamPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel!
    
    private lazy var parentViewController: NSViewController = {
        return NSApp.keyWindow!.contentViewController!
    }()
    private var cameraViewController: CameraViewController?

    required init(channel: FlutterMethodChannel) {
        self.channel = channel
            
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.matthewriemer.macam/method",
            binaryMessenger: registrar.messenger
        )
        let instance = MacamPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "open" {
            open(call: call, result: result)
        } else if call.method == "close" {
            close(self, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func sendFileBack(result: @escaping FlutterResult, path: String){
        sendFile(self, result: result, path: path)
    }
    
    private func open(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]

        if cameraViewController == nil {
            let parentFrame = parentViewController.view.frame
            let hidden = args["hidden"] as! Bool
            var width = 0.0
            var height = 0.0
            
            if(!hidden){
                width = parentFrame.size.width
                height = parentFrame.size.height
            }
            
            cameraViewController = CameraViewController(
                channel: channel,
                frame: CGRect(
                    x: parentFrame.origin.x,
                    y: parentFrame.origin.y,
                    width: width,
                    height: height
                ),
                macamPlugin: self,
                flutterResult: result,
                buttonTitle: args["buttonTitle"] as! String,
                fileName: args["fileName"] as! String,
                isVideo: args["isVideo"] as! Bool,
                recordingDuration: args["recordingDuration"] as! Int,
                isHidden: hidden
            )
        }
        guard let webViewCtrl = cameraViewController else {
            result(FlutterError(
                code: "CONTROLLER_NOT_INITIALIZED",
                message: "Controller not initialized, nothing to present",
                details: nil
            ))
            return
        }
        

        // webViewCtrl.loadUrl(url: url)
                
        if (!parentViewController.presentedViewControllers!.contains(webViewCtrl)) {
            parentViewController.presentAsSheet(webViewCtrl)
            //close(_:)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(close(_:)),
                name: kWebViewCloseNotification,
                object: nil
            )
            
            // channel.invokeMethod("onOpen", arguments: nil)
            // TODO: window
        }
        //result(nil)
    }
    
    @objc private func close(_ sender: Any?) {
        guard let webViewCtrl = cameraViewController else { return }

        if (parentViewController.presentedViewControllers!.contains(webViewCtrl)) {
            parentViewController.dismiss(webViewCtrl)
        }
        cameraViewController = nil
        
        NotificationCenter.default.removeObserver(
            self,
            name: kWebViewCloseNotification,
            object: nil
        )
        
//        channel.invokeMethod("onReceivedFile", arguments: nil)
    }
    
    private func sendFile(_ sender: Any?, result: @escaping FlutterResult, path: String) {
        close(sender)
        result(path)
    }
    
     private func close(_ sender: Any?, result: @escaping FlutterResult) {
         close(sender)
         result(nil)
     }
}
