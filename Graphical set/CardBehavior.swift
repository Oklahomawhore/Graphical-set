//
//  CardBehavior.swift
//  Graphical set
//
//  Created by Wangshu Zhu on 2018/9/7.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    
    private func push (_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2 * CGFloat.pi).arc4random
        push.magnitude = CGFloat(3.0) + CGFloat(2.0).arc4random
        push.action = {[unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item:UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item:UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
