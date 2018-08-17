//
//  ViewController.swift
//  ImagePick
//
//  Created by yjs001 on 2018/8/9.
//  Copyright © 2018年 jyb. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker = UIImagePickerController()
        picker.delegate = self
    }

    @IBAction func btn1(_ sender: UIButton) {
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btn2(_ sender: UIButton) {
        photoAuthorization()
    }
    
    func presentPhotoVc() {
        let viewController = JYBImagePickerController(nibName: "JYBImagePickerController", bundle: Bundle.main)
        let nav = UINavigationController(rootViewController: viewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    /**
     相册授权
     */
    private func photoAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:// 用户明确拒绝
            let alertController = UIAlertController(title: nil, message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "确定", style: .default) { (action) in
                //跳转
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(confirm)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:// 尚未请求,立即请求
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {// 用户同意
                    DispatchQueue.main.async {
                        self.presentPhotoVc()
                    }
                }
            }
        case .restricted://没有相册访问权限
            let alertController = UIAlertController(title: nil, message: "没有相册访问权限", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        case .authorized:// 用户已授权
            self.presentPhotoVc()
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController", picker)
        print(info)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel", picker)
        self.dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("willShow", viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("didShow", viewController)
    }
    
//    //屏幕旋转
//    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
//
//    }
//
//    //设备方向
//    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
//
//    }
//
//    //自定义转场
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//    }
//
//    //自定义转场
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

