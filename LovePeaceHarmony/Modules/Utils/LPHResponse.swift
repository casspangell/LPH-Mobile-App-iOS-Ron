//
//  LPHException.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 09/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public class LPHResponse<T, E> {
    
    private var isSucess: Bool = Bool()
    private var serverMessage: String = String()
    private var data: T?
    private var metadata: AnyObject?
    private var totalCount: Int = Int()
    private var sentItemsCount: Int = Int()
    private var lphException: LPHException<E>?
    private var isSessionExpired = false
    
    func setCalfException(lphException: LPHException<E>) {
        self.lphException = lphException
        self.isSucess = false
        self.serverMessage = lphException.errorMessage
    }
    
    func setSucess(isSucess: Bool) {
        self.isSucess = isSucess
    }
    
    func isSuccess() -> Bool {
        return isSucess
    }
    
    func getServerMessage() -> String {
        return serverMessage
    }
    
    func setServerMessage(serverMessage: String) {
        self.serverMessage = serverMessage
    }
    
    func setResult(data: T) {
        self.data = data
        self.isSucess = true
    }
    
    func getResult() -> T {
        return data!
    }
    
    func setMetadata(metadata: AnyObject) {
        self.metadata = metadata
    }
    
    func getMetadata() -> AnyObject? {
        return metadata
    }
    
    func setSessionExpiry(isExpired: Bool) {
        self.isSessionExpired = isExpired
    }
    
    func getSessionExpiry() -> Bool {
        return isSessionExpired
    }
    
    func getTotalCount() -> Int {
        return totalCount
    }
    
    func setTotalCount(totalCount: Int) {
        self.totalCount = totalCount
    }
    
    func getSentItemsCount() -> Int {
        return sentItemsCount
    }
    
    func setSentItemsCount(sentItemsCount: Int) {
        self.sentItemsCount = sentItemsCount
    }
    
}
