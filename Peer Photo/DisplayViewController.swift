//
//  DisplayViewController.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/11/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DisplayViewController: UIViewController {
    
    var peerIndex = Int()
    var timeRemaining = 10
    var timer = Timer()
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        if peersIDList[peerIndex].images.count > 0 {
            peersIDList[peerIndex].images.removeFirst()
        }
    }
    
    @objc func decTimer() {
        if timeRemaining > 1 {
            timeRemaining = timeRemaining-1
            timerLabel.text = String(timeRemaining)
        } else {
            timer.invalidate()
            removeImage()
        }
    }
    
    
    @IBAction func skipForward(_ sender: Any) {
        timer.invalidate()
        removeImage()
    }
    
    
    func removeImage() {
        peersIDList[peerIndex].images.removeFirst()
        if peersIDList[peerIndex].images.count > 0 {
            showImage()
        } else {
            performSegue(withIdentifier: "getOut", sender: self)
        }
    }
    
    func showImage() {
       imageView.image = peersIDList[peerIndex].images.first
        timeRemaining = 10
        timerLabel.text = String(timeRemaining)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(decTimer)), userInfo: nil, repeats: true)
    }
}
