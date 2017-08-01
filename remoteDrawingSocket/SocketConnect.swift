//
//  SocketConnect.swift
//  remoteDrawingSocket
//
//  Created by Anthony Da Cruz on 20/02/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import Foundation
import SocketIO

class SocketConnect {
    
    static let sharedInstance = SocketConnect()
    
    private let socket : SocketIOClient
    
    init() {
        
        let configurationDev:SocketIOClientConfiguration = [
                .log(false),
                .forceNew(false),
                .secure(false)]
        
        self.socket = SocketIOClient(socketURL: URL(string: "http://192.168.1.96:3000")!, config: configurationDev)
        
        self.addHandlers()
        self.socket.connect()
    }
    
    public func loginTest(){
        self.socket.emit("login")
    }
    
    public func emit(event: String, data: [Any]? = nil){
        if let dataToSend = data {
            self.socket.emit(event, with: dataToSend)
        }else{
            self.socket.emit(event, with: [Any]())
        }
    }
    
    public func addOn(event: String, callback: @escaping NormalCallback ) {
        self.socket.on(event, callback: callback)
    }
    
    private func addHandlers(){
        self.socket.on("connect") { data, ack in
            
        }
    }
}
