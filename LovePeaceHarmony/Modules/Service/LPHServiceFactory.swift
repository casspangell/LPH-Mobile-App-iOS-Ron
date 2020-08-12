//
//  LPHServiceFactory.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public class LPHServiceFactory<E> {
    
    public static func getLPHService() throws -> LPHService {
        
        var lphService: LPHService?
        if LPHUtils.checkNetworkConnection() {
            lphService = LPHServiceImpl()
        } else {
            throw LPHException<E>(applicationError: .noNetwork)
        }
        return lphService!
        
    }
    
}
