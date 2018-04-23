//
//  PeerStruct.swift
//  Peer Photo
//
//  Created by Daniel Fletcher on 12/11/17.
//  Copyright © 2017 Fletcher&Pflueger. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

struct PeerStruct {
    var name:String
    var peerID:MCPeerID
    var images:[UIImage]
    
    init(peerID: MCPeerID) {
        self.name = peerID.displayName
        self.peerID = peerID
        images = [UIImage]()
    }
    
    mutating func addImage(image: UIImage) {
        self.images.append(image)
    }
    
    mutating func removeImage(image: UIImage) {
        self.images.removeFirst()
    }

}
