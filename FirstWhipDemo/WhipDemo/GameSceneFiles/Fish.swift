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
        
        // MARK- QUESTA PARTE E' FONDAMENTALE!
        // Dato che il trofeo viene mostrato soltanto se il pesce viene pescato
        // Possivmo salvare allo stesso tempo anche l'avvenuta cattura per segnalarlo alla collezione
        if !savingCenter.getSavedBool(key: String("collectionTrophy-\(self.getPageNumber())-\(typeSpawned)-\(raritySpawned)")) {
            savingCenter.saveBool(dataToSave: true, key: String("collectionTrophy-\(self.getPageNumber())-\(typeSpawned)-\(raritySpawned)"))
            //Viene updatata la collezione se vi è stato un cambiamento nello stato
            collection.updateCollection()
        }
        
    }
    
    private func animate(){
        
        // Viene dichiarata l'azione che lo fa muovere in alto verso il centro
        let moveUpAction1 = SKAction.moveTo(y: 320, duration: 1.5)
        // Viene dichiarata l'azione che lo fa muovere verso l'alto dal centro
        let moveUpAction2 = SKAction.moveTo(y: 1100, duration: 1.2)
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
        // QUI CI VA L'ALGORITMO PER SCEGLIERE LE TEXTURE ED IL TROFEO SULLA BASE DELLE RARITA' E TIPOLOGIE
        let trophyTexture = SKTexture(imageNamed: "fish11")
        self.rarityTrophy.texture = trophyTexture
        
        // Texture per il pesce
        // QUI CI VA L'ALGORITMO PER SCEGLIERE LE TEXTURE ED IL TROFEO SULLA BASE DELLE RARITA' E TIPOLOGIE
        let fishTexture1 = SKTexture(imageNamed: "fish21")
        let fishTexture2 = SKTexture(imageNamed: "fish22")
        self.fish.texture = fishTexture1
        self.resetTrophyPosition()
        
        // Animazione infinita del pesce
        // QUI CI VA L'ALGORITMO PER SCEGLIERE LE TEXTURE ED IL TROFEO SULLA BASE DELLE RARITA' E TIPOLOGIE
        let fishAnimSeuquence = SKAction.animate(with: [fishTexture1, fishTexture2], timePerFrame: 0.3)
        animatefish = SKAction.repeatForever(fishAnimSeuquence)
        
        
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
        self.rarityTrophy.size = CGSize(width: 1231, height: 1162)
        self.rarityTrophy.position = CGPoint(x: 0, y: -800)
        self.fish.size = CGSize(width: 380, height: 1162)
        self.fish.removeAllActions()
    }
    
    
}

