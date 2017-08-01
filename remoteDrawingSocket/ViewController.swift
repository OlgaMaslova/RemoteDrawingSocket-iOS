//
//  ViewController.swift
//  remoteDrawingSocket
//
//  Created by Anthony Da Cruz on 20/02/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit
import SwiftMessages

class ViewController: UIViewController, SocketDrawingDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var changeBackground: UIButton!
    
    @IBOutlet weak var changeColor: UIButton!
    
    @IBOutlet weak var changeRoomField: UITextField!
    
    @IBOutlet weak var changeRoomButton: UIButton!
    
    @IBOutlet weak var receiveDrawing: UIButton!
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var room:String?
    var newRoom:String = "General"
    var color:String?
    var pseudo:String?
    var fromArray = [CGPoint]()
    var toArray = [CGPoint]()
    
    
    enum user {
        case me
        case other
    }
    
    var socketDrawingConnection = SocketDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeRoomField.delegate = self
        socketDrawingConnection.delegate = self
        self.socketDrawingConnection.receiveDataOnUser();
        self.mainImageView.backgroundColor = UIColor.lightGray;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            
            draw(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            draw(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        
    }
    

    func draw(fromPoint from: CGPoint, toPoint to:CGPoint, who user:ViewController.user = .me) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        // 2
        context?.move(to: from)
        context?.addLine(to: to)
        
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        
        
        context?.setStrokeColor(((UIColor(hexString: (color)!))?.cgColor)!)
        
        context?.setBlendMode(CGBlendMode.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        
        //Todo : send
        UIGraphicsEndImageContext()
        
        if user == .me {
            fromArray.append(from)
            toArray.append(to)
            print(toArray)
            self.socketDrawingConnection.sendCoordinates(from: from, to: to)
        }
        
    }
    
    func isDrawing(from: CGPoint, to: CGPoint, otherscolor: String, drawer: String) {
        color = otherscolor
        let drawer = drawer
        self.draw(fromPoint: from, toPoint: to, who: .other)
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        if drawer == pseudo {
            return
        }
        let notification = MessageView.viewFromNib(layout: .StatusLine)
        notification.configureTheme(.info)
        notification.configureDropShadow()
        notification.configureContent(body: "\(drawer) is drawing")
        SwiftMessages.show(view: notification)
    }
    
    func loggedIn(userExists: PropertyWithMessage?) {
        return
    }
    
    func usersData(me: Profil?) {
        guard let thisUser = me
            else {
                print ("no user information")
                return
        }
        color = thisUser.color
        room = thisUser.room
        pseudo = thisUser.pseudo
        
    }
    
    func colorReceived(color: String?) {
        
        if let newBackground = color {
            self.mainImageView.backgroundColor = (UIColor(hexString: newBackground))
            return
        }
        print("newBackground was not created")
    }
    
    func newColorReceived(newColor: PropertyWithMessage?) {
        guard let msg = newColor?.msg else {
            return
        }
        if msg {
            self.brushWidth = 30
            color = newColor?.property
            let notification = MessageView.viewFromNib(layout: .CardView)
            notification.configureTheme(.info)
            notification.configureDropShadow()
            notification.configureContent(title: "Warning", body: "You are eraser!")
            SwiftMessages.show(view: notification)

            return
        }
        self.brushWidth = 10
        color = newColor?.property
    }
    
    func clear () {
        mainImageView.image = nil
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newRoom = textField.text!
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.socketDrawingConnection.logOut()
    }
    //MARK: Actions
    
    @IBAction func changeBackground(_ sender: UIButton) {
        fetchBackground(sender: sender)
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        fetchBackground(sender: sender)
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        mainImageView.image = nil
        self.socketDrawingConnection.clearRoom()
    }
    
    @IBAction func changeRoom(_ sender: UIButton) {
        if newRoom == room {
            let notification = MessageView.viewFromNib(layout: .CardView)
            notification.configureTheme(.info)
            notification.configureDropShadow()
            notification.configureContent(title: "Warning", body: "You are already in this room!")
            SwiftMessages.show(view: notification)
            return
        }
        
        self.socketDrawingConnection.changeRoom(newRoom : newRoom)
        mainImageView.image = nil
        navigationItem.title = newRoom
        newRoom  = "General"
        self.socketDrawingConnection.receiveDataOnUser()
    
    }
    
    @IBAction func receiveDrawing(_ sender: UIButton) {
        
        for (index, value) in fromArray.enumerated() {
            let from = value
            let to = toArray[index]
            self.draw(fromPoint: from, toPoint: to, who: .me)
        }
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil

    }
    
    //MARK: Private methods
    
    private func fetchBackground (sender : UIButton)  {
        guard let backgroundColor = self.mainImageView.backgroundColor?.hexString(false) else{
            return
        }
        
        self.socketDrawingConnection.sendBackgroundColor(color: backgroundColor, sender: sender)
        print("Background color \(backgroundColor) is sent")
    }
    
}


