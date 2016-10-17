//
//  ClosedMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 20/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class ClosedMessageController: NSObject, MessageControllerProtocol {
    let closeStreamFunction: () -> ()
    
    init (closeStreamFunction: () -> ()) {
        self.closeStreamFunction = closeStreamFunction
        super.init()
    }
    
    func handle(message: Message) {
        closeStreamFunction()
    }

}
