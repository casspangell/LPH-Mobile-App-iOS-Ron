//
//  LPHException.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public class LPHException<E>: Error {
    
    private var applicationError: ApplicationError?
    private var controllerError: E?
    var errorMessage: String = String()
    var exceptionType: ExceptionType?
    
    public enum ExceptionType: Int {
        case application
        case controller
    }
    
    init(applicationError: ApplicationError) {
        self.exceptionType = .application
        self.applicationError = applicationError
        self.errorMessage = getApplicationErrorMessage()
        print("Exception thrown: \(self.errorMessage)")
    }
    
    init(controllerError: E) {
        self.exceptionType = .controller
        self.controllerError = controllerError
        self.errorMessage = getControllerErrorMessage()
        print("Exception thrown: \(self.errorMessage)")
    }
    
    init(controllerError: E, message: String) {
        self.exceptionType = .controller
        self.controllerError = controllerError
        self.errorMessage = message
        print("Exception thrown: \(self.errorMessage)")
    }
    
    private func getControllerErrorMessage() -> String {
        var errorMessage: String?
        switch controllerError {
        case is LoginError:
            errorMessage = getLoginErrorMessage(loginError: controllerError as! LoginError)
            break
        default:
            break
        }
        return errorMessage!
    }
    
    private func getApplicationErrorMessage() -> String {
        var errorMessage: String?
        switch applicationError! {
        case .noNetwork:
            errorMessage = AlertMessage.noNetwork
            break
        default:
            errorMessage = AlertMessage.unKnownException
            break
        }
        return errorMessage!
    }
    
    
    
    private func getLoginErrorMessage(loginError: LoginError) -> String {
        var message: String?
        switch loginError {
            
        case .emptyName:
            message = AlertMessage.nameEmpty
            break
            
        case .emptyEmail:
            message = AlertMessage.emailEmpty
            break
            
        case .invalidEmail:
            message = AlertMessage.invalidEmail
            break
            
        case .emptyPassword:
            message = AlertMessage.passwordEmpty
            break
            
        case .emptyConfirmPassword:
            message = AlertMessage.confirmPasswordEmpty
            break
            
        case .passwordDoNotMatch:
            message = AlertMessage.passwordDoNotMatch
            break
            
        default:
            message = AlertMessage.unKnownException
            break
        }
        return message!
    }
    
}
