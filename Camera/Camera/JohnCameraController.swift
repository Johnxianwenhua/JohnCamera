//
//  JohnCameraController.swift
//  Camera
//
//  Created by holdtime on 2017/10/19.
//  Copyright © 2017年 www.bthdtm.com 豪德天沐移动事业部. All rights reserved.
//

import UIKit
import AVFoundation

protocol JohnCameraControllerProtocol {
    
    func JohnCameraDidFinishPickingMediaWith(_ camera:UIViewController, image:UIImage?, error:NSError?)
    func JohnCameraDidCancel(_ camera:UIViewController)
}

class JohnCameraController: UIViewController {
    
    let session = AVCaptureSession()
    var delegate: JohnCameraControllerProtocol? = nil
    var deviceOutput:AVCaptureOutput? = nil

    @IBOutlet weak var tCameraAction: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var device:AVCaptureDevice! = nil
        //配置设备
        if #available(iOS 10.0, *) {
            guard let currentDevice = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first else {
                let error = NSError(domain: "Get Device Error - Input1", code: 1001, userInfo: nil)
                print(error.localizedDescription)
                if delegate != nil {
                    delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                }
                return
            }
            device = currentDevice
        } else {
            // Fallback on earlier versions
            for subDevice in AVCaptureDevice.devices(for: .video){
                if subDevice.position == AVCaptureDevice.Position.front{
                    device = subDevice
                }
            }
            if device == nil {
                let error = NSError(domain: "Get Device Error - Input1", code: 1001, userInfo: nil)
                print(error.localizedDescription)
                if delegate != nil {
                    delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                }
                return
            }
        }
        
        do {
            try device.lockForConfiguration()
        }catch let error{
            print(error.localizedDescription)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error as NSError)
            }
        }
        
        if device.isExposurePointOfInterestSupported {
            device.exposureMode = .continuousAutoExposure
        }
        
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus){
            device.focusMode = .autoFocus
        }
        
        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance){
            device.whiteBalanceMode = .autoWhiteBalance
        }
        
        device.unlockForConfiguration()
        
        var deviceInput:AVCaptureDeviceInput? = nil
        
        if #available(iOS 11.0, *) {
            
            let deviceOutput11 = AVCapturePhotoOutput()
            
            deviceOutput11.photoSettingsForSceneMonitoring = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
            
            deviceOutput = deviceOutput11
        } else {
            // Fallback on earlier versions
            let deviceOutput10 = AVCaptureStillImageOutput()
            deviceOutput10.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG,
                                             AVVideoScalingModeKey:AVVideoScalingModeResize]
            
            deviceOutput = deviceOutput10
            
        }
        
        //配置输入源 输出源
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
            
        }catch let error {
            print(error.localizedDescription)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error as NSError)
            }
        }
        
        //配置Session
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        //输入
        if let input = deviceInput {
            if session.canAddInput(input){
                session.addInput(input)
            }else {
                let error = NSError(domain: "Can Not Add Input - Session", code: 1002, userInfo: nil)
                print(error.localizedDescription)
                if delegate != nil {
                    delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                }
            }
        }else {
            let error = NSError(domain: "Get Input Error - Session", code: 1003, userInfo: nil)
            print(error.localizedDescription)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
            }
        }
        //输出
        if let output = deviceOutput {
            if session.canAddOutput(output) {
                session.addOutput(output)
            }else{
                let error = NSError(domain: "Can Not Add Output - Session", code: 1004, userInfo: nil)
                print(error.localizedDescription)
                if delegate != nil {
                    delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                }
            }
        }else {
            let error = NSError(domain: "Get Output Error - Session", code: 1005, userInfo: nil)
            print(error.localizedDescription)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
            }
        }
        
        //渲染
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        
        //装载
        view.layer.addSublayer(preview)
        
        //启动
        session.startRunning()
        view.bringSubview(toFront: tCameraAction)

    }
    
    @IBAction func tCameraActionEvent(_ sender: Any) {
        
        guard deviceOutput != nil else {
            return
        }
        //截取图片
        if #available(iOS 11.0, *) {
            (deviceOutput as! AVCapturePhotoOutput).capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg]), delegate: self)
        } else {
            // Fallback on earlier versions
            
            guard let stillConnection = (deviceOutput as! AVCaptureStillImageOutput).connection(with: AVMediaType.video) else{
                
                let error = NSError(domain: "Get Output Error - StillImageOutput", code: 1006, userInfo: nil)
                print(error.localizedDescription)
                if delegate != nil {
                    delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                }
                
                return
            }
            
            (deviceOutput as! AVCaptureStillImageOutput).captureStillImageAsynchronously(from: stillConnection, completionHandler: { (buffer, error) in
                guard (error == nil) else{
                    let error = NSError(domain: "Get Output Error - StillImageOutput", code: 1007, userInfo: nil)
                    print(error.localizedDescription)
                    if self.delegate != nil {
                        self.delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                    }
                    return
                }
                if let imagebuffer = buffer {
                    if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imagebuffer){
                        let image = UIImage(data: imageData)
                        if self.delegate != nil {
                            self.delegate?.JohnCameraDidFinishPickingMediaWith(self, image: image, error: nil)
                        }
                    }else{
                        let error = NSError(domain: "Get Convet Image Error - ImageBuffer", code: 1009, userInfo: nil)
                        print(error.localizedDescription)
                        if self.delegate != nil {
                            self.delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                        }
                    }
                    
                }else{
                    let error = NSError(domain: "Get Output Error - Image10", code: 1008, userInfo: nil)
                    print(error.localizedDescription)
                    if self.delegate != nil {
                        self.delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
                    }
                }
                
                
            })
        }
        
    }
    
}

extension JohnCameraController:AVCapturePhotoCaptureDelegate{
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: image, error: nil)
            }
        }else{
            let error = NSError(domain: "Get Output Error - Image11", code: 1007, userInfo: nil)
            print(error.localizedDescription)
            if delegate != nil {
                delegate?.JohnCameraDidFinishPickingMediaWith(self, image: nil, error: error)
            }
        }
    }
}

