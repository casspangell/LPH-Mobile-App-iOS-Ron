//
//  ApplicationError.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public enum ApplicationError: Int, Error {
    
    case noNetwork
    case inValidToken
    case outDatedBuild
    case deprecatedApiVersion
    case apiFailed
    case unknownException
    
}
