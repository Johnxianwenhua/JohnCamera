//
//  ViewController.swift
//  Camera
//
//  Created by holdtime on 2017/10/19.
//  Copyright © 2017年 www.bthdtm.com 豪德天沐移动事业部. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var tCameraAction: UIButton!
    
    @IBAction func tCameraActionEcent(_ sender: Any) {
        
//        let captureStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
//        
//        guard captureStatus == .authorized else{
//            
//            let alert = UIAlertController(title: "提示", message: "人脸识别需要获取相机权限", preferredStyle: .alert)
//            
//            let camearaction = UIAlertAction(title: "好", style: .default) { (alert) in
//                
//                self.dismiss(animated: true, completion: nil)
//            }
//            
//            alert.addAction(camearaction)
//            
//            self.present(alert, animated: true, completion: nil)
//            
//            return
//        }
        
        self.present(JohnCameraController(), animated: true, completion: nil)
    }
}

