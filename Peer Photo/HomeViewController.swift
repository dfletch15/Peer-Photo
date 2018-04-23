//
//  HomeViewController.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/8/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import UIKit

var peersIDList = [PeerStruct]()
let peerService = PeerManager()

class HomeViewController: UIViewController {
    
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
    }
    
    
    
}
