//
//  SignUpError.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public enum LoginError: Int, Error {
    case emptyName
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case emptyConfirmPassword
    case passwordDoNotMatch
    case invalidCredentials
}
