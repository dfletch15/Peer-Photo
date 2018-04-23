//
//  FriendListController.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/9/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FriendListController: UIViewController {
    
    
    var isSender = false
    
    @IBOutlet weak var myTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        peerService.delegate = self
        updateList(updatedList: peerService.session.connectedPeers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DisplayViewController {
            
            if let cell = sender as? PeerCell, let indexPath = myTable.indexPath(for: cell) {
                controller.peerIndex = indexPath.row
                myTable.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    
    func sendPhoto(image: UIImage) {
        var peersToSendTo = [MCPeerID]()
        for i in 0..<myTable.numberOfRows(inSection: 0){
            let cell = myTable.cellForRow(at: IndexPath(row: i, section: 0)) as! SendCell
            if cell.sendSwitch.isOn {
                peersToSendTo.append(peersIDList[i].peerID)
            }
        }
        
        peerService.send(image: image, peers: peersToSendTo)
    }
    
    
    
    func updateList(updatedList: [MCPeerID]) {
        var i = 0
        for peer in peersIDList {
            if !updatedList.contains(peer.peerID) { //remove disconnected peer
                peersIDList.remove(at: i)
            }
            i += 1
        }

        for newPeer in updatedList {
            var contains = false
             for currentPeer in peersIDList {
                if currentPeer.peerID == newPeer {
                    contains = true
                    continue
                }
            }
            
            if !contains {
                peersIDList.append(PeerStruct(peerID: newPeer))
            }
            
        }
        
        self.myTable.reloadData()
    }
    
}


extension FriendListController : PeerManagerDelegate {
    
    func recievedPhoto(from peerID: MCPeerID, image: UIImage) {
        var i = 0
        for peer in peersIDList {
            if peer.peerID == peerID {
                peersIDList[i].addImage(image: image)
            }
            i += 1
        }
        
        if !isSender {
            OperationQueue.main.addOperation {
                self.myTable.reloadData()
            }
        }
    }
    
    
    func connectedDevicesChanged(manager: PeerManager, connectedDevices: [MCPeerID]) {
        OperationQueue.main.addOperation {
            self.updateList(updatedList: connectedDevices)
        }
    }
}


extension FriendListController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return peersIDList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isSender {
            
            let theCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeerCell
            theCell.nameLabel.text = peersIDList[indexPath.row].name
            let count = peersIDList[indexPath.row].images.count
            theCell.numPendingLabel.text = "\(count)"
            if count > 0 {
                theCell.isUserInteractionEnabled = true
            } else {
                theCell.isUserInteractionEnabled = false
            }
            
            return theCell
        }
        else {
            
            let theCell = tableView.dequeueReusableCell(withIdentifier: "sendCell", for: indexPath) as! SendCell
            theCell.nameLabel.text = peersIDList[indexPath.row].name
            
            return theCell
        }
    }
    
    
    
}
