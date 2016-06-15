//
//  ViewController.swift
//  ReactiveSwift
//
//  Created by Waratnan Suriyasorn on 6/2/2559 BE.
//  Copyright © 2559 Chi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInFailureText: UILabel!
    
    var passwordIsValid = false
    var usernameIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIState()
        
        let validUsernameSignal = self.usernameTextField.rac_textSignal()
            .map { text in
                
                let value = text as! String
                print(value)
                let isValid = self.isValidUserName(value)
                return isValid
        }
        
        let validPasswordSignal = self.passwordTextField.rac_textSignal()
            .map { text in
                
                let value = text as! String
                let isValid = self.isValidPassword(value)
                return isValid
        }
        
        validUsernameSignal.subscribeNext { [weak weakSelf = self](valid) in
            let isValid = valid as! Bool
            weakSelf?.usernameTextField.backgroundColor = weakSelf?.backgroundColorForValidState(isValid)
        }
        
        validPasswordSignal.subscribeNext { [weak weakSelf = self](valid) in
            let isValid = valid as! Bool
            weakSelf?.passwordTextField.backgroundColor = weakSelf?.backgroundColorForValidState(isValid)
            
        }
        
        let signUpActiveSignal = RACSignal.combineLatest([validUsernameSignal, validPasswordSignal])
        
        signUpActiveSignal.subscribeNext { [weak weakSelf = self](value) in
            
            let tupe = value as! RACTuple
            let isUserNameValid = tupe.first as! Bool
            let isPwdValid = tupe.second as! Bool
            
            weakSelf?.signInButton.enabled = (isUserNameValid && isPwdValid)
        }
        
        self.signInButton.rac_signalForControlEvents(.TouchUpInside)
            .doNext{ [weak weakSelf = self](id) in
                weakSelf?.signInButton.enabled = false
                weakSelf?.signInFailureText.hidden = true
            }
            .flattenMap { [weak weakSelf = self](id) -> RACStream! in
                return weakSelf?.signInSignal()
            }.subscribeNext { [weak weakSelf = self](value) in
                
                let success = value as! Bool
                weakSelf?.signInButton.enabled = success
                weakSelf?.signInFailureText.hidden = false
                if success {
                    weakSelf?.performSegueWithIdentifier("signInSuccess", sender: self)
                }
        }
    }
    
    @IBAction func signInButtonTouched(sender: UIButton) {
    }
    
    private func isValidUserName(text: String) -> Bool {
        return text.characters.count > 3
    }
    
    private func isValidPassword(text: String) -> Bool {
        return text.characters.count > 3
    }
    
    private func updateUIState() {
        self.signInButton.enabled = passwordIsValid && usernameIsValid
    }
    
    private func backgroundColorForValidState(valid: Bool) -> UIColor {
        return valid ? UIColor.clearColor() : UIColor.redColor()
    }
    
    private func signInSignal() -> RACSignal
    {
        return RACSignal.createSignal { (subscriber) in
            subscriber.sendNext(true)
            subscriber.sendCompleted()
            return nil
        }
    }
}

