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

@objc protocol SocketDrawingDelegate {
    @objc optional func isDrawing(from: CGPoint, to: CGPoint, otherscolor: String, drawer: String)
    @objc optional func loggedIn (userExists: PropertyWithMessage?)
    @objc optional func usersData (me:Profil?)
    @objc optional func colorReceived (color: String?)
    @objc optional func newColorReceived (newColor: PropertyWithMessage?)
    @objc optional func clear()

    
}

@objc public class Profil:NSObject {
    var pseudo:String?
    var color:String?
    var room:String?
}
@objc public class PropertyWithMessage:NSObject{
    var msg:Bool?
    var property:String?
}



class SocketDrawing {
    
    private let webSocket = SocketConnect.sharedInstance
    
    public var delegate:NSObject?
    
    public var me:Profil?
    
    public var newBackgroundColor:String?
    
    public var newColor:PropertyWithMessage?
    
    public var userExists:PropertyWithMessage?
    
    
    
    init() {
        self.addHandlers()
        
    }

    
    public func sendCoordinates(from lastPoint:CGPoint, to toPoint:CGPoint){
        
        
        let lastPointJson:JSON = ["x" : lastPoint.x,"y" : lastPoint.y ]
        
        let toPointJson:JSON = ["x" : toPoint.x, "y" : toPoint.y]
        
        var objectToSend:JSON = ["old" : lastPointJson, "new" : toPointJson]
        
        self.webSocket.emit(event: "drawing", data: [objectToSend.dictionaryObject] as [Any])
    }
    
    public func sendBackgroundColor (color: String, sender: UIButton){
        
        let backgroundColorJson:JSON = ["color" : color]
        
        let button = sender.currentTitle!
        
        switch button {
            case "Change Color":
                self.webSocket.emit(event: "colorChanging", data: [backgroundColorJson.dictionaryObject] as [Any])
            case "Change Background":
                self.webSocket.emit(event: "backgroundChange", data: [backgroundColorJson.dictionaryObject] as [Any])
            default:
                print("don't know which button was pressed")
        }
    }
    
    public func sendNameRoom (name: String, room: String) {
        
        let objectToSend:JSON = ["name" : name, "room" : room]
        
        self.webSocket.emit(event: "login", data: [objectToSend.dictionaryObject] as [Any])
    }
    
    public func changeRoom (newRoom: String) {
        
        let newRoom:JSON = ["room" : newRoom]
        
        self.webSocket.emit(event: "changeRoom", data: [newRoom.dictionaryObject] as [Any])
    
    }
    
    public func receiveDataOnUser () {
        self.webSocket.emit(event: "me", data: nil)
    }
    
    public func clearRoom() {
        self.webSocket.emit(event: "clearRoom", data: nil)
    }

    
    public func logOut() {
        self.webSocket.emit(event: "disconnect", data: nil)
    }
    
    
    
    private func addHandlers(){
        self.webSocket.addOn(event: "sendUserData") { data, ack in
            let dataJSON = JSON(data[0])
            self.me = Profil()
            self.me?.color = dataJSON["color"].stringValue
            self.me?.room = dataJSON["room"].stringValue
            self.me?.pseudo = dataJSON["pseudo"].stringValue
            //print("my drawing color \(String(describing: self.me?.color))" )
            
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            delegate.usersData!(me: self.me)
            
        }
        
        self.webSocket.addOn(event: "userExists") { (data, ack) in
            let dataJSON = JSON(data[0])
            self.userExists = PropertyWithMessage()
            self.userExists?.msg = dataJSON["userExists"].boolValue
            self.userExists?.property = dataJSON["room"].stringValue
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            
            delegate.loggedIn!(userExists: self.userExists)
        }
        
    
        self.webSocket.addOn(event: "receiveDrawing") { data, ack in
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            let dataJSON = JSON(data[0])
            //print(dataJSON)
            if dataJSON["coordinates"].exists() && dataJSON["drawer"].exists() {
                guard
                    let xNew = dataJSON["coordinates"]["new"]["x"].float,
                    let yNew = dataJSON["coordinates"]["new"]["y"].float,
                    let xOld = dataJSON["coordinates"]["old"]["x"].float,
                    let yOld = dataJSON["coordinates"]["old"]["y"].float else {
                    return
                }
                let color = dataJSON ["color"].stringValue
                let drawer = dataJSON ["drawer"].stringValue
                delegate.isDrawing!(from: CGPoint(x: CGFloat(xOld), y: CGFloat(yOld)), to:CGPoint(x: CGFloat(xNew), y: CGFloat(yNew)), otherscolor: color, drawer: drawer)
            }
        }
        self.webSocket.addOn(event: "newBackground") { (data, ack) in
            let dataJSON = JSON(data[0])
            self.newBackgroundColor = dataJSON["color"].stringValue
            print("received background color \(self.newBackgroundColor ?? "no color received")")
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            delegate.colorReceived!(color: self.newBackgroundColor)
       
        }
        
        self.webSocket.addOn(event: "newColor") { (data, ack) in
            let dataJSON = JSON(data[0])
            self.newColor = PropertyWithMessage()
            self.newColor?.msg = dataJSON["eraser"].boolValue
            self.newColor?.property = dataJSON["color"].stringValue
            print("new drawing color \(self.newColor?.property ?? "no color received")")
            print(self.newColor?.msg ?? true)
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            delegate.newColorReceived!(newColor: self.newColor)
         }
        
        self.webSocket.addOn(event: "clearRoom") { (data, ack) in
            guard let delegate = self.delegate as? SocketDrawingDelegate else {
                return
            }
            delegate.clear!()
        }
        
    }
}
