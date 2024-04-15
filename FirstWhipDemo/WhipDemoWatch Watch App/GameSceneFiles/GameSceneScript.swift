
import SpriteKit
import Foundation
import SwiftUI

var setSemaferoGreen = false
var setSemaferoRed = true

class GameSceneScript: SKScene, SKPhysicsContactDelegate{
    
    var autolock = true
    var flag = true
    var lockType = true
    var lockRarity = true
    var viewModel: ViewModel!
    var simulation: SimulazionePesce!
    var foregroundLoop = ForegroundLoop()
    var semafero = SKSpriteNode()
    var fadeIn = SKAction()
    var fadeOut = SKAction()
    var youCanWhip = SKAction()
    
    
    override func sceneDidLoad() {
        // Si inizializza la scena
        self.initialize()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //Si imposta il semaforo al colore verde quando trow è vero
        if viewModel.canTrow == 1 && !setSemaferoGreen{
            setSemaferoGreen = true
            // AckNowledgement
            viewModel.sendMessage(key: "canTrowRecieved", value: 1)
            
        }
        // AckNowledgement
        if viewModel.canTrowSecondSignal == 1 {
            viewModel.sendMessage(key: "canTrowSecondSignalRecieved", value: 1)
        }
        
        // altrimenti si imposta il semaforo su rosso
        if viewModel.canTrow == 0 && !setSemaferoRed {
            setSemaferoRed = true
        }
        // Si gestiscono i semafori
        self.setSemaphores()
        // Funzione per gestire l'inizio della simulazione e segnalare il tutto
        self.setStartSimulation()
        // si controllano che i dati di pesca siano arrivati
        self.checkFishDataArrived()
        // Si controllano i casi di vittoria per eventuali eventi
        self.checkVictoryCondition()
    }

    
    // Funzione che controlla se ci sono casi di vittoria
    private func checkVictoryCondition(){
        // Si controllano se ci sono state delle condizioni di vittoria
        if condizioneVittoria == 0 || condizioneVittoria == 1 || condizioneVittoria == 2 {
            //Si resetta il valore iniziale della condizione di vittoria
            self.autolock = true
            
            switch condizioneVittoria {
                
            case 0:
                print("Invio il segnale di Vittoria.")
                viewModel.sendMessage(key: "FineSimulazione", value: 0)
                
            case 1:
                print("Invio il segnale di Sconfitta.")
                viewModel.sendMessage(key: "FineSimulazione", value: 1)
                
            case 2:
                print("Invio del segnale di rottura lenza.")
                viewModel.sendMessage(key: "FineSimulazione", value: 2)
                
            default:
                print("CondizioneVittoria Buggata. Valore \(condizioneVittoria)")

            }

            condizioneVittoria = -1
            viewModel.fineSimulazione = -1

        }
    }
    
    // Questa funzione gestisce la logica per preparare il terreno dell'inizio della simulazione
    private func setStartSimulation(){
        
        // si controlla che si possa iniziare la simulazione
        if (viewModel.inizioSimulazione == 1) && autolock {
            print("Inizio Simulazione")
            
            // Si resettano i valori di entrambi i viewModel
            viewModel.inizioSimulazione = 0
            viewModel.sendMessage(key: "InizioSimulazione", value: 0)
            
            // Si blocca l'accesso alla funzione e si inizia la simulazione
            self.autolock = false
            
            // Si resettano i valori di trow in entrambi i viewModel
            viewModel.trow = 0
            viewModel.sendMessage(key: "trow", value: 0)
            
            // Viene segnalato all'iphone che il segnale è stato ricevuto
            viewModel.sendMessage(key: "startSimulationRecieved", value: 1)
        }
    }
    
    // Questa funzione controlla che i dati del pesce siano arrivati, in tal caso si inizia la simulaizone
    private func checkFishDataArrived(){
        
        // Se è arrivato il segnale indicante il tipo spawnato viene segnalato
        if viewModel.typeSpawned != -1 && lockType{
            self.lockType = false
        }
        
        // Se è arrivato il segnale indicante la rarità viene segnalato
        if viewModel.choosedRarity != -1 && lockRarity {
            self.lockRarity = false
        }
        
        // Se entrambi i segnali sono arrivati inizia la simulazione
        // con i due dati generati
        if !lockRarity && !lockType {
            // Vengono resettate le flag
            self.lockType = true
            self.lockRarity = true
            // viene iniziata la simulazione con i dati ricevuti
            simulation.simulate(type: viewModel.typeSpawned, rarity: viewModel.choosedRarity)
            // si resettano i dati nel viewModel
            self.viewModel.choosedRarity = -1
            self.viewModel.typeSpawned = -1
            
            
        }
    }
    
    // Questa funzione quando invocata gestisce i semafori per indicare se mostrare o no
    // la scritta you can whip
    func setSemaphores(){
        
        // Si toglie la scritta "You Can Whip"
        if setSemaferoRed {
            setSemaferoRed = false
            self.semafero.run(fadeOut)
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false){ _ in
                self.semafero.run(self.fadeOut)
            }
        }
        
        // Si mostra la scritta "You Can Whip"
        if setSemaferoGreen {
            setSemaferoGreen = false
            self.semafero.run(SKAction.group([fadeIn, youCanWhip]))
        }
        
    }
    
    func initialize(){
        // Setto il backGround a trasparente
        self.backgroundColor = UIColor.black
        
        // Sprite di animaizone della scritta youCanWhip
        let canWhip1 = SKTexture(imageNamed: "canWhip1")
        let canWhip2 = SKTexture(imageNamed: "canWhip2")
        
        self.semafero = childNode(withName: "youCanWhip") as! SKSpriteNode
        self.semafero.zPosition = 20
        self.semafero.alpha = 0
        setSemaferoRed = true
        
        //Queste due azioni modificano l'alpha da 0 ad 1 e viceversa
        fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.7)
        
        // Animaizoni per la scritta "You Can Whip"
        youCanWhip = SKAction.animate(with: [canWhip1, canWhip2], timePerFrame: 0.35)
        youCanWhip = SKAction.repeatForever(youCanWhip)
        
    }
    
    func setViewModel(viewModel: ViewModel ){
        
        self.viewModel = viewModel
        
        self.simulation = SimulazionePesce(viewModel: viewModel)
    }
    
}
