//
//  PhotoViewController.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/8/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    //MARK: - Object definition
    var shouldAppear = true
    var previousHeight:CGFloat = 150.00
    var bottomOffset:CGFloat!
    var hasText = false
    var swiped = false
    var isDrawing = false
    var lastPoint:CGPoint!
    var drawingLayers = [UIImageView]()
    var currentLayer = UIImageView()
    var lineThickness = CGFloat()
    
    @IBOutlet weak var takenImage: UIImageView!
    @IBOutlet weak var imageFrame: UIView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var theTextView: UITextView!
    @IBOutlet weak var textBackground: UIView!
    @IBOutlet var dragger: UIPanGestureRecognizer!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    
    //MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHides(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        bottomOffset = self.view.frame.size.height - (imageFrame.frame.origin.y + imageFrame.frame.size.height)
        
        print(self.view.frame.maxY)
        print(imageFrame.frame.maxY)
        print(bottomOffset)
        self.view.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldAppear { presentCam(); shouldAppear = false }
    }
    
    
    @IBAction func unwindToCamera(segue: UIStoryboardSegue) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SendPhotoViewController {
            controller.theImage = createImage()
        }
    }
    
    
    
    //MARK: - Keyboard Notifications
    
    @objc func keyboardChanged(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.bottomSpace.constant = keyboardSize.height - (self?.bottomOffset)!
                self?.view.layoutIfNeeded()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardHides(notification: NSNotification) {
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bottomSpace.constant = (self?.previousHeight)!
            self?.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func toggleKeyboard(_ sender: Any) {
        if hasText {
            theTextView.resignFirstResponder()
            if theTextView.text.count < 1 {
                hideTextField()
            }
        } else {
            showTextField()
        }
    }
    
    
    //MARK: - TextView Functions
    
    func adjustUITextViewHeight(arg : UITextView){
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    
    
    func showTextField() {
        hasText = true 
        textBackground.isHidden = false
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bottomSpace.constant = (self?.previousHeight)!
            self?.view.layoutIfNeeded()
        }
        theTextView.becomeFirstResponder()
    }
    
    
    
    func hideTextField() {
        hasText = false
        textBackground.isHidden = true
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bottomSpace.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func dragTextField(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let bottomHeight = bottomSpace.constant - translation.y + bottomOffset
        let topHeight = bottomHeight + textHeight.constant
        
        if bottomHeight >= imageFrame.frame.minY && topHeight <= imageFrame.frame.maxY {
            bottomSpace.constant = bottomSpace.constant - translation.y
            previousHeight = bottomSpace.constant
        }
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    //MARK: - Camera Functions
    
    @IBAction func pressedCameraButton(_ sender: Any) {  //Reset all variables, prepare for new image
        takenImage.image = nil
        bottomSpace.constant = 0
        previousHeight = 150
        textBackground.isHidden = true
        theTextView.text = ""
        hasText = false
        saveButton.alpha = 1
        saveButton.isEnabled = true
        
        while drawingLayers.count > 0 {  //remove each layer from superview
            drawingLayers.last?.removeFromSuperview()
            drawingLayers.removeLast()
        }
        
        isDrawing = false
        drawButton.setTitle("Draw", for: UIControlState.normal)
        tapRecognizer.isEnabled = true
        dragger.isEnabled = true
        undoButton.isHidden = true
        presentCam()
    }
    
    
    func presentCam() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: false, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        takenImage.image = image
        self.view.isHidden = false
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         self.performSegue(withIdentifier: "goHome", sender: self)
    }
    
    
    
    //MARK: - Image processing / sharing
    
    @IBAction func nativeShare(_ sender: Any) {
        //Luanch iOS sharing controller
        let items = [createImage()];
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil);
        self.present(activity, animated: true, completion: nil)
        
    }
    
    
    func createImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageFrame.bounds.size, imageFrame.isOpaque, 0.0)
        imageFrame.drawHierarchy(in: imageFrame.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    
    //MARK: - Drawing
    @IBAction func scaleLineSize(_ sender: Any) {
        //Feature not yet implemented
    }
    
    func getTempImageView(within superView: UIView) -> UIImageView {
        let newImageView = UIImageView()
        newImageView.frame = superView.bounds
        superView.addSubview(newImageView)
        
        return newImageView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDrawing {
            swiped = false
            currentLayer = getTempImageView(within: imageFrame)
            imageFrame.bringSubview(toFront: textBackground)
            imageFrame.bringSubview(toFront: theTextView)
            if let touch = touches.first {
                lastPoint = touch.location(in: currentLayer)
                currentLayer.image = drawLine(fromPoint: lastPoint, toPoint: lastPoint, into: currentLayer, theSize: currentLayer.frame.size, width: 8)
            }
            
        }
    }
    
    
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, into tempImage: UIImageView, theSize: CGSize, width: CGFloat) -> UIImage {
        
        let renderer1 = UIGraphicsImageRenderer(size: theSize)
        let img1 = renderer1.image { ctx in
            
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.setLineWidth(width)

            ctx.cgContext.move(to: fromPoint)
            ctx.cgContext.addLine(to: toPoint)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            
            let circlePath = UIBezierPath(arcCenter: toPoint, radius: width/2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
            
            ctx.cgContext.addPath(circlePath)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.closePath()
            ctx.cgContext.fillPath()

        }
        
        UIGraphicsBeginImageContextWithOptions(theSize, false, 0.0)
        tempImage.draw(tempImage.frame)
        img1.draw(in: tempImage.frame, blendMode:CGBlendMode.normal, alpha:1.0)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return temp!
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDrawing {
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: currentLayer)
                currentLayer.image = drawLine(fromPoint: lastPoint, toPoint: currentPoint, into: currentLayer, theSize: currentLayer.frame.size, width: 8)
                
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawing {
            
            if !swiped {
                // draw a single point
                currentLayer.image = drawLine(fromPoint: lastPoint, toPoint: lastPoint, into: currentLayer, theSize: currentLayer.frame.size, width: 8)
            }
            
            drawingLayers.append(currentLayer) //Add stroke to "undo" array
            
        }
    }
    
    @IBAction func undoStroke(_ sender: Any) {
        if drawingLayers.count > 0 {
            drawingLayers.last?.removeFromSuperview()
            drawingLayers.removeLast()
        }
    }
    
    @IBAction func toggleDrawing(_ sender: UIButton) {
        isDrawing = !isDrawing
        if isDrawing {
            drawButton.setTitle("Done", for: UIControlState.normal)
            tapRecognizer.isEnabled = false
            dragger.isEnabled = false
            undoButton.isHidden = false
            theTextView.isEditable = false
        } else {
            drawButton.setTitle("Draw", for: UIControlState.normal)
            tapRecognizer.isEnabled = true
            dragger.isEnabled = true
            undoButton.isHidden = true
            theTextView.isEditable = true
        }
    }
    
        
    
} //end of class





//MARK: - TextView Delegate
extension PhotoViewController:  UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textHeight.constant = size.height
        textView.setContentOffset(CGPoint.zero, animated: false)
        
        saveButton.alpha = 1
        saveButton.isEnabled = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        dragger.isEnabled = false
        drawButton.alpha = 0.6
        drawButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        dragger.isEnabled = true
        drawButton.alpha = 1
        drawButton.isEnabled = true
    }
}
