//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
//

import Foundation

public enum ZeusError: Error {
    public enum ResponseError: Error {
        case parsingKeysFailed(String)
    }
}
