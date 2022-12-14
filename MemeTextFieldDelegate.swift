//
//  MemeTextFieldDelegate.swift
//  Meme
//
//  Created by Jiajia Li on 12/13/22.
//

import Foundation
import UIKit

// MARK: - MemeTextFieldDelegate: NSObject, UITextFieldDelegate

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
