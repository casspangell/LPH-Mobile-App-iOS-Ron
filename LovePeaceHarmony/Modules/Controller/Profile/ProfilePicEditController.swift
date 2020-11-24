//
//  ProfilePicEditController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 20/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
//import Kingfisher

class ProfilePicEditController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables
    var refreshCallback: RefreshCallback?
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.profilePicUrl != "" {
//            imageViewProfilePic.kf.setImage(with: URL(string: loginVo.profilePicUrl))
        }
        imageViewProfilePic.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    // MARK: - IBOutlets
    @IBAction func onTapBack(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapCamera(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func onTapLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageViewProfilePic.image = selectedImage
        convertToBase64(image: selectedImage)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    private func convertToBase64(image: UIImage) {
        showLoadingIndicator()
        DispatchQueue.global(qos: .background).async {
            let imageData: NSData = UIImageJPEGRepresentation(image.updateImageOrientionUpSide()!, 0.4)! as NSData
            let base64UploadImage = String(data: imageData.base64EncodedData(options: .lineLength64Characters), encoding: String.Encoding.utf8)!
            DispatchQueue.main.async {
                self.updateProfilePic(base64: base64UploadImage)
            }
        }
    }
    
    private func processLoginResponse(fromServer response: LPHResponse<ProfileVo, LoginError>) {
        if response.isSuccess() {
            let loginVo = LPHUtils.getLoginVo()
            let profileVo = response.getResult()
            print(profileVo.name)
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.isLoggedIn = true
            loginVo.loginType = .email
            LPHUtils.setLoginVo(loginVo: loginVo)
            refreshCallback?.refresh()
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(title: "", message: response.getServerMessage(), vc: self)
        }
        hideLoadingIndicator()
    }
    
    // MARK: - Api
    private func updateProfilePic(base64 image: String) {
        showLoadingIndicator()
        do {
            let lphService = try LPHServiceFactory<LoginError>.getLPHService()
            lphService.updateProfilePic(base64Image: image, parsedResponse: { (lphResponse) in
                self.processLoginResponse(fromServer: lphResponse)
            })
        } catch let error as LPHException<NewsError> {
            self.hideLoadingIndicator()
            showToast(message: error.errorMessage)
        } catch let error {
            
        }
    }
    
}
