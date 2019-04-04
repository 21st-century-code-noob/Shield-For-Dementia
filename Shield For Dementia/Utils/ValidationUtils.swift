//
//  ValidationUtils.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import Foundation
class ValidationUtils{
    static func validateUsername(username: String!) -> Bool{
        var validated: Bool! = true
        
        let RegEx = "\\w{6,20}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        
        if username.isEmpty{
            validated = false
        }
        else if username.count == 0 || username.count > 20{
            validated  = false
        }
        
        else if Test.evaluate(with: username) == false{
            validated = false
        }
        
        return validated
    }
}
