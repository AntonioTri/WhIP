//
//  Fish.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 31/03/24.
//

import Foundation
import SpriteKit

class Fish{

    private var fish =  SKSpriteNode()
    private var rarityTrophy = SKSpriteNode()
    private var animatefish = SKAction()
    private var typeSpawned: Int!
    private var raritySpawned: Int!
    private var savingCenter: SavingsCenter!
    private var collection: FishCollection!
    
    var trophyAnimation = SKAction()
    
    init(scene: SKScene, savingCenter: SavingsCenter, collection: FishCollection) {
        self.rarityTrophy = scene.childNode(withName: "trophy") as! SKSpriteNode
        self.fish = (self.rarityTrophy.childNode(withName: "fishType") as! SKSpriteNode)
        self.savingCenter = savingCenter
        self.collection = collection
    }
    
    // Questa funzione setta un nuovo stato interno ed anima il trofeo con il nuovo stato
    func setNewInternalState(typeSpawned: Int, raritySpawned: Int){
        self.typeSpawned = typeSpawned
        self.raritySpawned = raritySpawned
        self.setTexturesAndAnimation()
        self.animate()
        
        // Dato che il trofeo viene mostrato soltanto se il pesce viene pescato
        // Possivmo salvare allo stesso tempo anche l'avvenuta cattura per segnalarlo alla collezione
        if !savingCenter.getSavedBool(key: String("collectionTrophy-\(self.getPageNumber())-\(typeSpawned)-\(raritySpawned)")) {
            savingCenter.saveBool(dataToSave: true, key: String("collectionTrophy-\(self.getPageNumber())-\(typeSpawned)-\(raritySpawned)"))
            //Viene updatata la collezione se vi è stato un cambiamento nello stato
            collection.updateCollection()
        }
        
    }
    
    private func animate(){
        
        print(self.rarityTrophy.size)
        // Viene dichiarata l'azione che lo fa muovere in alto verso il centro
        let moveUpAction1 = SKAction.moveTo(y: 350, duration: 1.5)
        // Viene dichiarata l'azione che lo fa muovere verso l'alto dal centro
        let moveUpAction2 = SKAction.moveTo(y: 1400, duration: 1.2)
        // Si crea la sequenza di animazioni
        let sequence = SKAction.sequence([moveUpAction1, SKAction.wait(forDuration: 2), moveUpAction2])
        // Si esegue la sequenza
        self.rarityTrophy.run(sequence)
        // Viene anche eseguita l'animazione sul nuovo pesce appena pescato
        self.fish.run(animatefish)
        // Dopo un breve lasso di tempo si resetta il trofeo in basso
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false){ _ in
            self.resetTrophyPosition()
        }
        
    }
    

    
    // Settiamo le nuove texture ed animation sulla base del nuovo stato interno
    private func setTexturesAndAnimation(){
        
        // Texture per il trofeo
        let trophyTexture = getTrophyTexture()
        self.rarityTrophy.texture = trophyTexture
        
        // Texture per il pesce
        let fishTexture1 = SKTexture(imageNamed: String("fish-\(self.typeSpawned!)-1"))
        print(fishTexture1)
        let fishTexture2 = SKTexture(imageNamed: String("fish-\(self.typeSpawned!)-1"))
        
        // settiamo lo stato iniziale
        self.fish.texture = fishTexture1
        self.fish.zPosition = self.rarityTrophy.zPosition + 1
        self.resetTrophyPosition()
        
        // Animazione infinita del pesce
        let fishAnimSeuquence = SKAction.animate(with: [fishTexture1, fishTexture2], timePerFrame: 0.3)
        animatefish = SKAction.repeatForever(fishAnimSeuquence)
        
        
    }
    
    // Questa funzione sceglie lo sfondo del trofeo dinamicamente in base alla rarità
    private func getTrophyTexture() -> SKTexture {
        
        switch self.raritySpawned {
        case 0:
            return SKTexture(imageNamed: "commonTrophy")
        case 1:
            return SKTexture(imageNamed: "rareTrophy")
        case 2:
            return SKTexture(imageNamed: "epicTrophy")
        case 3:
            return SKTexture(imageNamed: "legendaryTrophy")
        default:
            print("Error choosing trophy")
            return SKTexture()
        }

    }
    
    // Questa funzione sulla base del tipo spawnato indicizza la pagina del catalogoz di appartenenza
    private func getPageNumber() -> Int {
        
        switch typeSpawned {
        case 0, 1, 2, 3:
            return 1
        case 4, 5, 6, 7:
            return 2
        case 8, 9, 10, 11:
            return 3
        default:
            return 0
        }
    }
    
    private func resetTrophyPosition(){
        self.rarityTrophy.size = CGSize(width: 850, height: 800)
        self.rarityTrophy.position = CGPoint(x: 0, y: -800)
        self.fish.size = CGSize(width: 320, height: 850)
        self.fish.removeAllActions()
    }
    
    
}

