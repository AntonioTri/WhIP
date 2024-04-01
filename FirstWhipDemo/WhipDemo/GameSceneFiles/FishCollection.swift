//
//  Collection.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 31/03/24.
//

import Foundation
import SpriteKit

class FishCollection{
    
    private let scene: SKScriptIphone
    private var collectionNode = SKSpriteNode()
    private var UPButton = SKSpriteNode()
    private var DOWNButton = SKSpriteNode()
    private var BACKButton = SKSpriteNode()
    private var inGameCB = SKSpriteNode()
    //Queste due azioni modificano l'alpha da 0 ad 1 e viceversa
    private var fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
    private var fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.7)
    private var catalog: [SKSpriteNode] = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    private let savingCenter: SavingsCenter
    private var currentPageNumber = 0
    private var showPreviousPageButton = true
    private var showNextPageButton = true
    private var canPressCollectionButton = false
    
    init(scene: SKScriptIphone, savingCenter: SavingsCenter){
        
        self.scene = scene
        self.savingCenter = savingCenter
        // Vengono inizializzati gli elementi del catalogo principale
        self.initializeCatalogReferences()
        // Si inizializza lo stato di pagine iniziale
        self.updateInternalPageState()
    }
    
    
    // Questa funzione ci permette di far scorrere le pagine del catalogo sulla base di determinate condizioni
    func scrollPage(touch: UITouch){
        
        // Andiamo ad estrarre le coordinate del tocco
        let position = touch.location(in: scene)
        // Estraiamo dalla scena
        let touchedNode = scene.atPoint(position) as? SKSpriteNode
        let menu = scene.childNode(withName: "Menu") as! SKSpriteNode
        
        // Se si sta toccando il menu (o il bottone "collection" da inserire)
        // si fanno scorrere i due protagonisti, collezione e menu per mostrare la collezione
        if touchedNode == menu {
            
            menu.run(SKAction.group([SKAction.moveTo(x: 1600, duration: 0.8), fadeOut]))
            collectionNode.run(SKAction.group([SKAction.moveTo(x: 0, duration: 0.8), fadeIn]))
            
        // Nel caso si stia toccando il bottone per vedere i trofei, si gestisce la situazione in base ai casi
        } else if touchedNode == inGameCB && self.canPressCollectionButton {
            
            self.scene.hideGamingScene()
            self.hideCollectionButton()
            self.inGameCB.run(fadeOut)
            collectionNode.run(SKAction.group([SKAction.moveTo(x: 0, duration: 0.8), fadeIn]))
          
        // nell'altro caso, se si sta toccando il bottone BACKButton
        // Si ritorna al menu
        }else if touchedNode == BACKButton {
            
            self.turnBackToPreviousState()
            
        // ALtrimenti se si sta toccando l'UPButton, vengono eseguite delle operazioni
        // Per scorrere la pagina da quella attuale alla precedente
        // Giocando con i valori alpha e zposition per nascondere e rendere non interagibili
        // Determinate pagine
        } else if touchedNode == UPButton && showPreviousPageButton {
            
            self.currentPageNumber -= 1
            self.catalog[currentPageNumber].alpha = 1
            self.catalog[currentPageNumber].zPosition = 10
            self.catalog[currentPageNumber + 1].alpha = 0
            self.catalog[currentPageNumber + 1].zPosition = -10
            // Viene updatato lo stato sulla base della pagina corrente
            // Andando a settare anche le flag per l'interazione con i bottoni
            // e nascondendoli/ mostrandoli
            self.updateInternalPageState()
            
        // Lo stesso viene fatto per il DOWN Button
        } else if touchedNode == DOWNButton && showNextPageButton {

            self.currentPageNumber += 1
            self.catalog[currentPageNumber].alpha = 1
            self.catalog[currentPageNumber].zPosition = 10
            self.catalog[currentPageNumber - 1].alpha = 0
            self.catalog[currentPageNumber - 1].zPosition = -10
            // Viene updatato lo stato sulla base della pagina corrente
            // Andando a settare anche le flag per l'interazione con i bottoni
            // e nascondendoli/ mostrandoli
            self.updateInternalPageState()
            
        }
        
        // Test per osservare i dati dei nodi cliccati
        
//        print("\n----DOPO I CONTROLLI----\n")
//        print(touchedNode!)
//        print("\n-----DOWNBUTTON:\n\(DOWNButton)\n")
//        print("-----UPBUTTON:\n\(UPButton)\n")
//        
//        print("UPButton name: \(UPButton.name ?? "ERROR"), state: \(showPreviousPageButton)")
//        print("NEXTButton name: \(DOWNButton.name ?? "ERROR"), state: \(showNextPageButton)\n\n")
        
    }
    
    // Questa funzione quando invocata associa ad ogni immagine nella collezione,
    // quella colorata corrispettiva se il pesce è stato pescato, altrimenti una immagine scura
    func updateCollection(){
        
        
        for pageNumber in 1...3 {
            // Andiamo ad estrarre la pagina corrente del menù dei collezionabili
            let page = collectionNode.childNode(withName: String("page\(pageNumber)")) as! SKSpriteNode
            
            // Sulla base del numero pagina, andiamo a controllare se al suo interno vi è stato
            // Un cambiamento nello stato dei pesci collezionati ed in tal caso andiamo a cambiarlo
            switch pageNumber {
            case 1:
                // La prima pagina contiene le specie dalla 0 all 3
                checkPage(pageToCheck: page, pageNumber: pageNumber, startIndex: 0, endingIndex: 3)
            case 2:
                // La seconda dalla 4 alla 7
                checkPage(pageToCheck: page, pageNumber: pageNumber, startIndex: 4, endingIndex: 7)
            case 3:
                // La terza dalla 8 alla 9 + le due righe per gli oggetti di lore
                checkPage(pageToCheck: page, pageNumber: pageNumber, startIndex: 8, endingIndex: 11)
            default:
                print("Errore nella creazione della pagina")
                
            }
        }
    }
    
    // Questa funzione prende in input una pagina, il suo indirizzo e d il numero iniziale e finale del
    // numero di specie che contiene.
    private func checkPage(pageToCheck: SKSpriteNode, pageNumber: Int, startIndex: Int, endingIndex: Int){
        
        // Si scorrono le specie nell'intervallo definito
        for n in startIndex...endingIndex {
            // Si scorrono le colonne
            for m in 0...3 {
                // Si interpola la stringa rappresentante il nome del trofeo
                let currentName = String("collectionTrophy-\(pageNumber)-\(n)-\(m)")
                // Il trofeo esiste nella scena sicuramente, pertanto viene preso
                let currentTrophy = pageToCheck.childNode(withName: currentName) as! SKSpriteNode
                // Se all'interno del database il suo valore è salvato come booleano allora viene mostrata
                // L'immagine del trofeo corrispondente
                if savingCenter.getSavedBool(key: currentName) {
                    currentTrophy.texture = SKTexture(imageNamed: "fish11")
                    // Altrimenti viene mostrato uno spot vuoto
                } else {
                    currentTrophy.texture = SKTexture(imageNamed: "fish22")
                }
            }
        }
    }
    
    // Quando richiamata questa funzione imposta delle flag per mostrare o nascondere
    // I bottoni di scorrimento pagina in base alla pagina corrente
    private func updateInternalPageState(){
        
        // Se ci troviamo nella pagina 0 viene mostrato il bottone giù
        // e nascoto il bottone sù
        if self.currentPageNumber == 0 {
            self.showPreviousPageButton = false
            self.showNextPageButton = true
        // Se ci troviamo nella pagina 2, su viene mostrato e giù nascosto
        } else if self.currentPageNumber == 2 {
            self.showPreviousPageButton = true
            self.showNextPageButton = false
        // Altrimenti si mostrano entrambi
        } else {
            self.showPreviousPageButton = true
            self.showNextPageButton = true
        }
        
        // Viene richiamato l'update dello stato interno dei bottoni
        // Per farli comparire o scomparire in base all'occasione
        self.updateButtonsState()
        
    }
    
    // Questa funzione aggiorna lo stato visivo dei bottoni
    // Andandoli a nascondere o a mostrare sulla base dello stato attuale
    private func updateButtonsState(){
        
        // Se deve essere mostrato il bottono next viene impostato l'alpa a 1 altrimenti a 0
        if self.showPreviousPageButton {
            self.UPButton.alpha = 1
        } else {
            self.UPButton.alpha = 0
        }
        
        if self.showNextPageButton{
            self.DOWNButton.alpha = 1
        } else {
            self.DOWNButton.alpha = 0
        }
        
    }
    
    // Questa funzione serve quando si preme il tasto back, viene controllato qual'era
    // Lo stato precedente all'ingresso del menù delle collezioni, e sulla base di questo
    // viene mostrata la giusta scena precendente
    private func turnBackToPreviousState(){
        
        if scene.getCurrentState() == 0{
            
            self.scene.menu.run(SKAction.group([SKAction.moveTo(x: 0, duration: 0.8), fadeIn]))
            self.collectionNode.run(SKAction.group([SKAction.moveTo(x: -1600, duration: 0.8), fadeOut]))
            
        } else if scene.getCurrentState() == 1{
            
            self.scene.showGamingScene()
            self.collectionNode.run(SKAction.group([SKAction.moveTo(x: -1600, duration: 0.8), fadeOut]))
            
        }
        
    }
    
    func showCollectionbutton(){
        self.inGameCB.run(fadeIn)
        self.canPressCollectionButton = true
    }
    
    func hideCollectionButton(){
        self.inGameCB.run(fadeOut)
        self.canPressCollectionButton = false
    }


    // Si inizializzano gli elementi del catalogo
    private func initializeCatalogReferences(){
        
        // si ottiene una reference del catalogo principale
        self.collectionNode = scene.childNode(withName: "collectionNode") as! SKSpriteNode
        
        // Si ottengono reference a tutti i nodi figli principali
        self.catalog[0] = collectionNode.childNode(withName: "page1") as! SKSpriteNode
        self.catalog[1] = collectionNode.childNode(withName: "page2") as! SKSpriteNode
        self.catalog[2] = collectionNode.childNode(withName: "page3") as! SKSpriteNode
        self.catalog[1].alpha = 0
        self.catalog[2].alpha = 0
        self.UPButton = collectionNode.childNode(withName: "UPButton") as! SKSpriteNode
        self.DOWNButton = collectionNode.childNode(withName: "DOWNButton") as! SKSpriteNode
        self.BACKButton = collectionNode.childNode(withName: "BACKButton") as! SKSpriteNode
        self.inGameCB = scene.childNode(withName: "showCollection") as! SKSpriteNode
        
    }
    
}
