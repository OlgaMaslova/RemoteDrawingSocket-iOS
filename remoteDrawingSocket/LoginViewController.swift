//
//  LoginViewController.swift
//  remoteDrawingSocket
//
//  Created by Olga on 27/07/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, SocketDrawingDelegate {
    
    //MARK: properties

    @IBOutlet weak var NameField: UITextField!

    @IBOutlet weak var RoomField: UITextField!

    @IBOutlet weak var SubmitButton: UIButton!
    
    var socketDrawingConnection = SocketDrawing()
    
    var name:String = ""
    var room:String = "General"
    var logged:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketDrawingConnection.delegate = self
        NameField.delegate = self
        RoomField.delegate = self
        
        SubmitButton.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loggedIn(userExists: PropertyWithMessage?) {
        guard let userInfo = userExists else {
        return
        }
        
        if userInfo.msg! {
            let alert = UIAlertController(title: "Alarm", message: "This username exixts already!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        room = userInfo.property!
        performSegue(withIdentifier: "loggedIn", sender: self)
    }
    
    func usersData(me: Profil?) {
        return
    }
    func colorReceived(color: String?) {
        return
    }
    func newColorReceived(newColor: PropertyWithMessage?) {
        return
    }
    func isDrawing(from: CGPoint, to: CGPoint, otherscolor: String, drawer: String) {
        return
    }
    func clear() {
        return
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn" {
            let target = segue.destination
            target.navigationItem.title = room
        }
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == NameField {
            name = textField.text ?? ""
            SubmitButton.isEnabled = !name.isEmpty
            return
        }
        room = textField.text!
    }
    
    //MARK: Actions
    

    @IBAction func submit(_ sender: UIButton) {
        
        self.socketDrawingConnection.sendNameRoom(name: name, room: room)
        
    }
}
