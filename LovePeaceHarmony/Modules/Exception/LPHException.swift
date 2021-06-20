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
            errorMessage = NSLocalizedString(AlertMessage.noNetwork, comment: "")
            break
        default:
            errorMessage = NSLocalizedString(AlertMessage.unKnownException, comment: "")
            break
        }
        return errorMessage!
    }
    
    
    
    private func getLoginErrorMessage(loginError: LoginError) -> String {
        var message: String?
        switch loginError {
            
        case .emptyName:
            message = NSLocalizedString(AlertMessage.nameEmpty, comment: "")
            break
            
        case .emptyEmail:
            message = NSLocalizedString(AlertMessage.emailEmpty, comment: "")
            break
            
        case .invalidEmail:
            message = NSLocalizedString(AlertMessage.invalidEmail, comment: "")
            break
            
        case .passwordLength:
            message = NSLocalizedString(AlertMessage.passwordLength, comment: "")
            break
            
        case .emptyPassword:
            message = NSLocalizedString(AlertMessage.passwordEmpty, comment: "")
            break
            
        case .emptyConfirmPassword:
            message = NSLocalizedString(AlertMessage.confirmPasswordEmpty, comment: "")
            break
            
        case .passwordDoNotMatch:
            message = NSLocalizedString(AlertMessage.passwordDoNotMatch, comment: "")
            break
            
        default:
            message = NSLocalizedString(AlertMessage.unKnownException, comment: "")
            break
        }
        return message!
    }
    
}
