//
//  SendPhotoViewController.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/9/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import UIKit


class SendPhotoViewController: UIViewController{
    

    var container:FriendListController?
    var theImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FriendListController {
            container = controller
            container!.isSender = true
        }
    }
    
    @IBAction func pressedSend(_ sender: Any) {
        container!.sendPhoto(image: theImage)
    }
    
}
