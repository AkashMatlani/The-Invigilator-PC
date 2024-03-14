import Cocoa
import FlutterMacOS
import AVFoundation
//import CustomButton
//import WebKit

// Camera Manager


enum CameraError: LocalizedError {
  case cannotDetectCameraDevice
  case cannotAddInput
  case previewLayerConnectionError
  case cannotAddOutput
  case videoSessionNil
  
  var localizedDescription: String {
    switch self {
    case .cannotDetectCameraDevice: return "Cannot detect camera device"
    case .cannotAddInput: return "Cannot add camera input"
    case .previewLayerConnectionError: return "Preview layer connection error"
    case .cannotAddOutput: return "Cannot add video output"
    case .videoSessionNil: return "Camera video session is nil"
    }
  }
}

typealias CameraCaptureOutput = AVCaptureOutput
typealias CameraSampleBuffer = CMSampleBuffer
typealias CameraCaptureConnection = AVCaptureConnection

protocol CameraManagerDelegate: AnyObject {
  func cameraManager(_ output: CameraCaptureOutput, didOutput sampleBuffer: CameraSampleBuffer, from connection: CameraCaptureConnection)
}

protocol CameraManagerProtocol: AnyObject {
  var delegate: CameraManagerDelegate? { get set }
  
  func startSession() throws
  func stopSession() throws
  func takePicture() throws
  func recordVideo() throws
}

final class CameraManager: NSObject, CameraManagerProtocol, AVCapturePhotoCaptureDelegate {
  
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private var videoSession: AVCaptureSession!
  private var cameraDevice: AVCaptureDevice!
  private var imageOutput: Any!
//  private var camSettings: Any!
  private let cameraQueue: DispatchQueue
    
  private let containerView: NSView
  private let mainView: NSView
  private let macamPlugin: MacamPlugin
  private var flutterResult: FlutterResult
  private var cameraView: CameraViewController
  
  weak var delegate: CameraManagerDelegate?
  
    init(containerView: NSView, mainView: NSView, macamPlugin: MacamPlugin, flutterResult: @escaping FlutterResult, cameraView: CameraViewController) throws {
    self.containerView = containerView
    self.mainView = mainView
    self.macamPlugin = macamPlugin
    self.flutterResult = flutterResult
    self.cameraView = cameraView
    cameraQueue = DispatchQueue(label: "sample buffer delegate", attributes: [])
    
    super.init()
    
    try prepareCamera()
  }
  
  deinit {
    previewLayer = nil
    videoSession = nil
    cameraDevice = nil
  }
  
  private func prepareCamera() throws {
    videoSession = AVCaptureSession()
    videoSession.sessionPreset = AVCaptureSession.Preset.photo
    previewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
    previewLayer.videoGravity = .resizeAspectFill
    
    let devices = AVCaptureDevice.devices()
    
    cameraDevice = devices.filter { $0.hasMediaType(.video) }.compactMap { $0 }.first
    
    if cameraDevice != nil  {
      do {
        let input = try AVCaptureDeviceInput(device: cameraDevice)
        if videoSession.canAddInput(input) {
          videoSession.addInput(input)
        } else {
          throw CameraError.cannotAddInput
        }
        
        if let connection = previewLayer.connection, connection.isVideoMirroringSupported {
          connection.automaticallyAdjustsVideoMirroring = false
          connection.isVideoMirrored = true
        } else {
          throw CameraError.previewLayerConnectionError
        }
        
        previewLayer.frame = containerView.bounds
        containerView.layer = previewLayer
        containerView.wantsLayer = true
        
      } catch {
        throw CameraError.cannotDetectCameraDevice
      }
    }
    
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: cameraQueue)
    if videoSession.canAddOutput(videoOutput) {
      videoSession.addOutput(videoOutput)
    } else {
      throw CameraError.cannotAddOutput
    }
  }
    
    
  func recordVideo() throws {
      let videoOutput = AVCaptureMovieFileOutput()
      let seconds: Float64 = Float64(self.cameraView.recordingDuration)
      videoOutput.maxRecordedDuration = CMTimeMakeWithSeconds(seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
      let input = try AVCaptureDeviceInput(device: cameraDevice)
      
      if(true){
          // Audio Input
          guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
              fatalError("No audio device found")
          }
          
          let audioInput = try AVCaptureDeviceInput(device: audioDevice)
          if videoSession.canAddInput(audioInput) {
              videoSession.addInput(audioInput)
          }
      }
      
      guard videoSession.canAddInput(input), videoSession.canAddOutput(videoOutput) else {
          print("Video input and output could not be added to the capture session")
          return
      }
      // Set the output file type to MP4
      videoOutput.movieFragmentInterval = .invalid
      videoSession.addInput(input)
      videoSession.addOutput(videoOutput)
      
      if #available(macOS 10.13, *) {
          videoOutput.setOutputSettings([AVVideoWidthKey: 1280, AVVideoHeightKey: 720, AVVideoCodecKey: AVVideoCodecType.h264], for: videoOutput.connection(with: AVMediaType.video)!)
      } else {
          // Fallback on earlier versions
      }
      videoSession.commitConfiguration()
      // start the recording
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURL = documentsURL.appendingPathComponent(self.cameraView.fileName + ".mp4")
      videoOutput.startRecording(to: fileURL, recordingDelegate: self)
      // stop the recording
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
          videoOutput.stopRecording()
      }
  }
    
  func takePicture() throws {
      if #available(macOS 10.15, *) {
          let camSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
          (self.imageOutput as AnyObject).capturePhoto(with: camSettings, delegate: self)
      } else {
          // Fallback on earlier versions
      }
  }
    
    //store the image
    @available(macOS 10.15, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = NSImage(data: imageData)!
            let imagePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            storeImageAsJPEG(image: image, imageName: self.cameraView.fileName, imagePath: imagePath!)
            let fullPath = imagePath! + "/" + self.cameraView.fileName + ".jpg"
            macamPlugin.sendFileBack(result: self.flutterResult, path: fullPath);
        }
    }
 
 
    func storeImageAsJPEG(image: NSImage, imageName: String, imagePath: String) {
        if let imageData = image.tiffRepresentation,
            let bitmapImageRep = NSBitmapImageRep(data: imageData) {
            let jpegData = bitmapImageRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])
            let imageFilePath = imagePath.appending("/\(imageName).jpg")
            try? jpegData!.write(to: URL(fileURLWithPath: imageFilePath), options: .atomicWrite)
        }
    }
    

  func startSession() throws {
    if let videoSession = videoSession {
      if !videoSession.isRunning {
        cameraQueue.async {
          videoSession.startRunning()
            // Add ability to store here
            if #available(macOS 10.15, *) {
                self.imageOutput = AVCapturePhotoOutput()
                videoSession.addOutput(self.imageOutput as! AVCaptureOutput)
            } else {
                // Fallback on earlier versions
            }
        }
      }
    } else {
      throw CameraError.videoSessionNil
    }
  }
  
  func stopSession() throws {
    if let videoSession = videoSession {
      if videoSession.isRunning {
        cameraQueue.async {
          videoSession.stopRunning()
        }
      }
    } else {
      throw CameraError.videoSessionNil
    }
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished recording to \(outputFileURL)")
        let mainPath = outputFileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
        macamPlugin.sendFileBack(result: self.flutterResult, path: mainPath);
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    delegate?.cameraManager(output, didOutput: sampleBuffer, from: connection)
  }
}

// End Camera Manager

let kWebViewCloseNotification = Notification.Name("SheetCloseNotification")
class CameraViewController: NSViewController {
    
    private let frame: CGRect
    private let channel: FlutterMethodChannel
    // private let presentationStyle: PresentationStyle
    private let buttonTitle: String
    private var cameraManager: CameraManagerProtocol!
    private var macamPlugin: MacamPlugin
    private var flutterResult: FlutterResult
    var actionButton: CustomButton
    let fileName: String
    let isVideo: Bool
    let recordingDuration: Int
    let isHidden: Bool
    
            
    required init(
        channel: FlutterMethodChannel,
        frame: NSRect,
        macamPlugin: MacamPlugin,
        flutterResult: @escaping FlutterResult,
        buttonTitle: String,
        fileName: String,
        isVideo: Bool,
        recordingDuration: Int,
        isHidden: Bool
    ) {
        self.channel = channel
        self.frame = frame
        self.macamPlugin = macamPlugin
        self.flutterResult = flutterResult
        // self.presentationStyle = presentationStyle
        self.buttonTitle = buttonTitle
        self.fileName = fileName
        self.isVideo = isVideo
        self.recordingDuration = recordingDuration
        self.isHidden = isHidden
        self.actionButton = CustomButton()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUrl(url: URL) {
    }
    
    @objc private func actionCamera() {
        do {
            if(self.isVideo){
                actionButton.backgroundColor = NSColor(red: 221/255, green: 48/255, blue: 32/255, alpha: 1)
                actionButton.title = "Recording.."
                actionButton.textColor = NSColor.white
                try cameraManager.recordVideo()
            } else {
                try cameraManager.takePicture()
            }

        } catch {
          // Cath the error here
          print(error.localizedDescription)
        }
        //self.view.window?.close()
    }
    
    private func runAfterDelay(seconds: Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    private func setupViews() {
        let myView = NSView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        myView.wantsLayer = true
        if(self.isHidden){
            myView.isHidden = true
        }
        myView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myView)

         var constraints: [NSLayoutConstraint] = [
             myView.topAnchor.constraint(equalTo: view.topAnchor),
             myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             myView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
         ]
        
        if(!self.isHidden){
            let bottomBarHeight: CGFloat = 60.0
            constraints.append(
                myView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -bottomBarHeight)
            )

            let bottomBar = NSView()
            bottomBar.wantsLayer = true
            bottomBar.layer?.backgroundColor = NSColor(red: 113.0/255, green: 187.0/255, blue: 174.0/255, alpha: 1).cgColor
            bottomBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomBar)
            
            constraints.append(contentsOf: [
                bottomBar.topAnchor.constraint(equalTo: myView.bottomAnchor),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bottomBar.heightAnchor.constraint(equalToConstant: bottomBarHeight),
            ])

            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.title = buttonTitle
            actionButton.font = NSFont.boldSystemFont(ofSize: 16)
            actionButton.backgroundColor = NSColor.white
            actionButton.borderWidth = 0.5
            actionButton.borderColor = NSColor(red: 47.0/255, green: 94.0/255, blue: 81.0/255, alpha: 1)
            actionButton.cornerRadius = 10
            actionButton.textColor = NSColor(red: 47.0/255, green: 94.0/255, blue: 81.0/255, alpha: 1)
            
            if(self.isVideo){
                actionButton.activeBackgroundColor = NSColor(red: 221/255, green: 48/255, blue: 32/255, alpha: 1)
                actionButton.activeTextColor = NSColor.white
            } else {
                actionButton.activeBackgroundColor = NSColor(red: 47.0/255, green: 94.0/255, blue: 81.0/255, alpha: 1)
                actionButton.activeTextColor = NSColor.white
            }
    
            actionButton.target = self
            actionButton.action = #selector(self.actionCamera)
            bottomBar.addSubview(actionButton)
            
            constraints.append(contentsOf: [
                actionButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
                actionButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
                actionButton.widthAnchor.constraint(equalToConstant: 140),
                actionButton.heightAnchor.constraint(equalToConstant:40)
            ])
        }
        
        do {
            cameraManager = try CameraManager(containerView: myView, mainView: self.view, macamPlugin: macamPlugin, flutterResult: self.flutterResult, cameraView: self)
            cameraManager.delegate = self
        } catch {
            print("Error: \(error)")
        }
        
        constraints.forEach { (c) in
            c.isActive = true
        }
    }
    
    override func loadView() {
        view = NSView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        
        if(self.isHidden){
            runAfterDelay(seconds: 2.0) {
                do {
                    try self.cameraManager.recordVideo()
                } catch {
                  print(error.localizedDescription)
                }

            }
        }
    }
    
    override var representedObject: Any? {
      didSet {
        // Update the view, if already loaded.
      }
    }
    
    override func viewDidAppear() {
      super.viewDidAppear()
    view.window?.delegate = self
      do {
        try cameraManager.startSession()
      } catch {
        // Cath the error here
        print(error.localizedDescription)
      }
    }
    
    override func viewDidDisappear() {
      super.viewDidDisappear()
      do {
        try cameraManager.stopSession()
      } catch {
        // Cath the error here
        print(error.localizedDescription)
      }
    }
    
}

extension CameraViewController: CameraManagerDelegate {
  func cameraManager(_ output: CameraCaptureOutput, didOutput sampleBuffer: CameraSampleBuffer, from connection: CameraCaptureConnection) {
    print(Date())
  }
}


extension CameraViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
            
    }
}
