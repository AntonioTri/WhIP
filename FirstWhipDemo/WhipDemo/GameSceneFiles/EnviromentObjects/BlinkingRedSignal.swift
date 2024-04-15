//
//  BlinkingRedSignal.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 13/04/24.
//

import Foundation
import SpriteKit

class BlinkingRedSignal {
    
    let scene: SKScriptIphone!
    var redSignal = SKSpriteNode()
    let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
    let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
    var blinking = SKAction()
    
    init(scene: SKScriptIphone!) {
        self.scene = scene
        self.redSignal = SKSpriteNode(imageNamed: "redSignal")
        self.createAnimations()
        self.redSignal.removeFromParent()
    }
    
    // funzione che inizia a far pulsare il segnale di pericolo rottura lenza
    func startBlinking(){
        self.scene.addChild(self.redSignal)
        self.redSignal.run(blinking)
    }
    
    // Segnale che fa smettere al nodo di pulsare
    func stopBlinking(){
        
        let removeAction = SKAction.run {
            self.redSignal.removeFromParent()
        }
        self.redSignal.removeAllActions()
        self.redSignal.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 0.2), removeAction]))
        
    }
    
    // funzione che crea delle semplici animazioni di blinking
    private func createAnimations(){
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        self.blinking = SKAction.repeatForever(sequence)
        self.redSignal.position = CGPoint(x: -630, y: 110)
        self.redSignal.size = CGSize(width: 180, height: 180)
        
    }

}

