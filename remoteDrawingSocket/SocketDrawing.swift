//
//  SocketDrawing.swift
//  remoteDrawingSocket
//
//  Created by Anthony Da Cruz on 20/02/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

protocol SocketDrawingDelegate {
    func isDrawing(from: CGPoint, to: CGPoint)
}
class SocketDrawing {
    
    private let webSocket = SocketConnect.sharedInstance
    
    public var delegate:NSObject?
    
    init() {
        self.addHandlers()
    }
    
    private func addHandlers(){
        
        self.webSocket.addOn(event: "receiveDrawing") { data, ack in
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            let dataJSON = JSON(data[0])
            print(dataJSON)
            if dataJSON["coordinates"].exists() && dataJSON["drawer"].exists() {
                guard
                    let xNew = dataJSON["coordinates"]["new"]["x"].float,
                    let yNew = dataJSON["coordinates"]["new"]["y"].float,
                    let xOld = dataJSON["coordinates"]["old"]["x"].float,
                    let yOld = dataJSON["coordinates"]["old"]["y"].float else {
                    return
                }
                print(dataJSON)
                delegate.isDrawing(from: CGPoint(x: CGFloat(xOld), y: CGFloat(yOld)), to:CGPoint(x: CGFloat(xNew), y: CGFloat(yNew)))
            }
        }
    }
}
