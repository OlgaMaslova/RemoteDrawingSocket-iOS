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
    
    
    public struct Profil {
        var id:String
        var color:String
    }
    
    public var me:Profil?
    
    init() {
        self.addHandlers()
        
    }
    
    public func login(){
        self.webSocket.emit(event: "login")
    }
    
    public func sendCoordinates(from lastPoint:CGPoint, to toPoint:CGPoint){
        
        
        let lastPointJson:JSON = ["x" : lastPoint.x,"y" : lastPoint.y ]
        
        let toPointJson:JSON = ["x" : toPoint.x, "y" : toPoint.y]
        
        var objectToSend:JSON = ["old" : lastPointJson, "new" : toPointJson]
        
        self.webSocket.emit(event: "drawing", data: [objectToSend.dictionaryObject] as [Any])
    }
    
    private func addHandlers(){
        self.webSocket.addOn(event: "me") { data, ack in
            let dataJSON = JSON(data[0])
            self.me = Profil(id: dataJSON["id"].stringValue, color: dataJSON["color"].stringValue)
        }
        
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
