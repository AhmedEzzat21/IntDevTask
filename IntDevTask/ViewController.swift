//
//  ViewController.swift
//  IntDevTask
//
//  Created by Ahmed Ezzat on 9/22/18.
//  Copyright © 2018 Ahmed Ezzat. All rights reserved.
//

import UIKit
import GoogleSignIn
//import Firebase



class ViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //adding the delegates
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        //getting the signin button and adding it to view
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.center = view.center
        view.addSubview(googleSignInButton)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //if any error stop and print the error
        if error != nil{
            print(error ?? "google error")
            return
        }
        else {
            print("\(user.profile.email)")
            
        }
        
        
        
        
    }
}
