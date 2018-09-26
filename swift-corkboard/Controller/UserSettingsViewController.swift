//
//  UserSettingsViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/11/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseFirestore
import Firebase
import FirebaseStorage
import FirebaseUI
import PusherSwift
import SwiftLinkPreview
import MobileCoreServices
import AVFoundation
import Photos

class UserSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let defaults = UserDefaults.standard
    let slp = SwiftLinkPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = defaults.string(forKey: "token")

        uploadUserImage()
    }
    
    //UPDATE INFORMATION FORM
    @IBOutlet var firstNameInput: UITextField!
    @IBOutlet var lastNameInput: UITextField!
    @IBOutlet var usernameInput: UITextField!
    @IBOutlet var newPasswordInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    @IBAction func saveUserChangesButton(_ sender: UIButton) {
        let first_name = firstNameInput.text
        let last_name = lastNameInput.text
        let username = usernameInput.text
        let password = newPasswordInput.text
        let email = passwordInput.text
        let userId = defaults.string(forKey: "userId")
        let url = "http://localhost:5000/updateUser/\(userId!)"
        let params = [ "first_name": first_name, "last_name": last_name, "username": username, "password": password, "email": email]
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let alert = UIAlertController(title: "Update Successful!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //ADD IMAGE
    @IBOutlet var userPhoto: UIImageView!
    
    func uploadUserImage() {
        let userId = defaults.string(forKey: "userId")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/users/\(userId).jpg")
        let imageView = self.userPhoto
        let placeholderImage = UIImage(named: "angle-mask.png")
        imageView?.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
    }
    
    @IBAction func updatePhotoButton(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            self.uploadImage(image, progressBlock: { (percentage) in
                print(percentage)
            }, completionBlock: { (fileURL, errorMessage) in
                print(errorMessage)
            })
        }
    }
    //UPLOAD IMAGE TO FIREBASE
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Double) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        print("UPLOAD!!!")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userId = defaults.string(forKey: "userId")
        let fileName = NSUUID().uuidString
        let imageRef = storageRef.child("images/users/\(userId).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.customMetadata = [
                "user_id": "\(userId!)"
            ]
            metadata.contentType = "image/jpeg"
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                imageRef.downloadURL(completion: { (url, error) in
                    if let metadata = metadata {
                        print("here's metadata")
                        print(metadata)
//                        self.addImageToDB(filename: fileName)
                        self.viewDidLoad()
                        return completionBlock( url, nil)
                    } else {
                        completionBlock(nil, error?.localizedDescription)
                    }
                })
            })
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                let percentage = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100
                progressBlock(percentage)
            })
        } else {
            completionBlock(nil, "Image not converted to data")
        }
    }
    


    
    //DELETE ACCOUNT
    @IBAction func deleteAccountButton(_ sender: UIButton) {
        let token = defaults.string(forKey: "token")
        let userId = defaults.string(forKey: "userId")
        let url = "http://localhost:5000/deleteUser/\(userId!)"
        let params = ["token" : token]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "Your Account Has Been Deleted", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let welcomeViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                        self.present(welcomeViewController, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    print("Succeeded")
                case .failure(let error):
        
                    let alert = UIAlertController(title: "Account could not be deleted", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                    print(error)
                }
        }
    }
    
    
    //BACK BUTTON
    @IBAction func backButton(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(mainViewController, animated: true, completion: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
