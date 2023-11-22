//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
//

import Foundation

/// ZeusWrapper
public struct ZeusWrapper<Base> {
    public var wrapper: Base
    init(_ wrapper: Base) {
        self.wrapper = wrapper
    }
}

public extension ZeusWrapper {
    func make(_ closure: (Base) -> Void) -> Self {
        closure(wrapper)
        return self
    }
    
    var print: Self {
        Swift.print(self)
        return self
    }
    
    var printWrapper: Self {
        Swift.print(wrapper)
        return self
    }
    
    var debugPrint: Self {
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Zeus DebugPrint", self)
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Zeus Wrapper Value", wrapper)
        return self
    }
    
    var debugPrintWrapper: Self {
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Zeus Wrapper Value", wrapper)
        return self
    }
}

public protocol ZeusCompatible {}
public extension ZeusCompatible {
    var zeus: ZeusWrapper<Self> { return ZeusWrapper(self) }
    static var zeus: ZeusWrapper<Self>.Type { ZeusWrapper<Self>.self }
}
