//
//  AttackNode.swift
//  Mastery
//
//  Created by Peter Cho on 10/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class AttackNode: CCNode {
   
    func didLoadFromCCB() {
        userInteractionEnabled = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        //only animation for attack here. Movement of the bullet/weapon implemented in gameplay physics node
        NSNotificationCenter.defaultCenter().postNotificationName("fireBasicBullet", object: nil)
    }
    
}
