//
//  ViewController.swift
//  Meme
//
//  Created by Jiajia Li on 12/12/22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var navigationBar: UINavigationBar!
    var shareButton: UIBarButtonItem!
//    var cancelButton: UIBarButtonItem!
    
    var toolbar: UIToolbar!
    var cameraButton: UIBarButtonItem!
    var albumButton: UIBarButtonItem!

    var imagePicked: UIImageView!
    var topText: UITextField!
    var bottomText: UITextField!

    var safeAreaTop: CGFloat!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var safeAreaBottom: CGFloat!
    let navigationBarHeight = CGFloat(44)
    let toolbarHieght = CGFloat(44)
    
    // define text attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "IMPACT", size: 40)!,
        NSAttributedString.Key.strokeWidth: 5,
    ]
    
    var textDelegate = MemeTextFieldDelegate()
    
    override func viewWillLayoutSubviews() {
        safeAreaTop = self.view.safeAreaInsets.top
        safeAreaBottom = self.view.safeAreaInsets.bottom

        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: safeAreaTop, width: screenWidth, height: navigationBarHeight))
        self.view.addSubview(navigationBar);

        let navigationItem = UINavigationItem()
        let shareButtonImage = UIImage(systemName: "square.and.arrow.up.fill")
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(cancel(_:)))
        shareButton = UIBarButtonItem(image: shareButtonImage, style: .plain, target: self, action: #selector(share(_:)))
        shareButton.isEnabled = (imagePicked.image != nil)
        navigationItem.leftBarButtonItem = shareButton
        navigationItem.rightBarButtonItem = cancelButton
        navigationBar.setItems([navigationItem], animated: false)
        
        self.toolbar = UIToolbar(frame: CGRect(x: 0, y: screenHeight - safeAreaBottom - 44, width: screenWidth, height: toolbarHieght))
        self.view.addSubview(self.toolbar);
        
        let cameraButtonImage = UIImage(systemName: "camera.fill")
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.toolbar.items =  [UIBarButtonItem(image: cameraButtonImage, style: .plain, target: self, action: #selector(pickAnyImagefromCamera(_:))),
                              UIBarButtonItem(title: "ALBUMS", style: .plain, target: self, action: #selector(pickAnyImage(_:)))]
        } else {
            toolbar.items =  [UIBarButtonItem(title: "ALBUMS", style: .plain, target: self, action: #selector(pickAnyImage(_:)))]
        }
    
       }

    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        safeAreaTop = self.view.safeAreaInsets.top
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        safeAreaBottom = self.view.safeAreaInsets.bottom
        
        self.imagePicked = UIImageView()
        self.imagePicked.frame = CGRect(x: 0, y: safeAreaTop + 44, width: screenWidth, height: screenHeight - safeAreaTop - navigationBarHeight - safeAreaBottom)
        self.imagePicked.backgroundColor = .black
        view.addSubview(self.imagePicked)
        
        self.topText = UITextField()
        self.topText.frame = CGRect(origin: CGPoint(x: screenWidth / 2 - 110, y: 150), size: CGSize(width: 220, height: 40))
        topText.adjustsFontSizeToFitWidth = true
        self.topText.textAlignment = .center // palceholder text is not centered ??
        self.topText.defaultTextAttributes = memeTextAttributes
        self.topText.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: memeTextAttributes)
        self.view.addSubview(self.topText)
        self.topText.delegate = textDelegate

        self.bottomText = UITextField()
        self.bottomText.frame = CGRect(origin: CGPoint(x: screenWidth / 2 - 110, y: 600), size: CGSize(width: 220, height: 40))
        self.bottomText.textAlignment = .center 
        self.bottomText.defaultTextAttributes = memeTextAttributes
        self.bottomText.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeTextAttributes)
        self.view.addSubview(bottomText)
        self.bottomText.delegate = textDelegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe keyboard notification
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromKeyboardHideNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)

        // subscribe keyboard notification
        subscribeToKeyboardNotifications()
        subscribeToKeyboardHideNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }

    func subscribeToKeyboardHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardHideNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    @objc func cancel(_ sender: Any)  {
        imagePicked.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
    }
    
    @objc func share(_ sender: Any) {
        let meme = generateMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities:  nil)
        activityViewController.excludedActivityTypes = [.addToReadingList,
                                                        .airDrop,
                                                        .assignToContact,
                                                        .copyToPasteboard,
                                                        .openInIBooks,
                                                        .print,
                                                        .saveToCameraRoll,
                                                        .postToWeibo,
                                                        .copyToPasteboard,
                                                        .saveToCameraRoll,
                                                        .postToFlickr,
                                                        .postToVimeo,
                                                        .postToTencentWeibo,
                                                        .markupAsPDF
        ]
        present(activityViewController, animated: true)
    }
    
    func generateMemedImage() -> UIImage {
        navigationBar.isHidden = true
        toolbar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        navigationBar.isHidden = false
        toolbar.isHidden = false
        return memedImage
    }
    
    
    @objc func pickAnyImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func pickAnyImagefromCamera(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // implement imagePickerController delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicked.image = image
            imagePickerControllerDidCancel(picker)
            shareButton.isEnabled = true
        } else {
            imagePicked.image = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
}

