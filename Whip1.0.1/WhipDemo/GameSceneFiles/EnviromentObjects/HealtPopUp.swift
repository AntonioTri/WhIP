//
//  HealtPopups.swift
//  WhipDemo
//
//  Created by Andrea Siniscalchi on 13/04/24.
//

import Foundation
import SpriteKit

class HealtPopups{
    
    let scene: SKScriptIphone!
    let healtNode = SKSpriteNode(imageNamed: "healUp")
    
    init(scene: SKScriptIphone!){
        self.scene = scene
        self.spawnHealtPopUp()
    }
    
    private func spawnHealtPopUp(){
        self.healtNode.position = self.findSpawnPoint()
        self.healtNode.size = CGSize(width: 160, height: 160)
        self.scene.addChild(self.healtNode)
        self.animatePopup()
    }
    
    private func findSpawnPoint() -> CGPoint{
        let xmin = -30
        let xmax = 200
        let xscelta = Int.random(in: xmin...xmax)
        let yscelta = Int.random(in: xscelta...xscelta+100)
        
        return CGPoint(x: xscelta, y: yscelta+250)
    }
    
    private func animatePopup(){
        
        self.healtNode.alpha = 0
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let removeNode = SKAction.run {
            self.healtNode.removeFromParent()
        }
        
        let sequence = SKAction.sequence([fadeIn, fadeOut, removeNode])
        let upMovement = SKAction.move(by: CGVector(dx: 0, dy: 70), duration: 0.6)
        let group = SKAction.group([sequence, upMovement])
        
        self.healtNode.run(group)
        
        
    }
}

