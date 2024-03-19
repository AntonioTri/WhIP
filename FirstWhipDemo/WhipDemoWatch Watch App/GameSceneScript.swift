
import SpriteKit
import Foundation
import SwiftUI

var setSemaferoGreen = false
var setSemaferoRed = true

class GameSceneScript: SKScene, SKPhysicsContactDelegate{
    
    var autolock = true
    var flag = true
    var viewModel: ViewModel!
    var simulation: SimulazionePesce!
    var semafero = SKSpriteNode()
    var fadeIn = SKAction()
    var fadeOut = SKAction()
    var youCanWhip = SKAction()
    
    override func sceneDidLoad() {
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
    
    override func update(_ currentTime: TimeInterval) {
        
        //Si imposta il semaforo al colore verde
        if viewModel.canTrow == 1 && !setSemaferoGreen{
            setSemaferoGreen = true
        }
        
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
        
        if (viewModel.inizioSimulazione == 1) && autolock {
            
            print("Inizio Simulazione")
            
            viewModel.inizioSimulazione = 0
            viewModel.sendMessage(key: "InizioSimulazione", value: 0)
            
            autolock = false
            simulation.simulate()
            
            viewModel.trow = 0
            viewModel.sendMessage(key: "trow", value: 0)
            
            // Viene segnalato all'iphone che il segnale è stato ricevuto
            viewModel.sendMessage(key: "startSimulationRecieved", value: 1)
            
        }
        
        
        if condizioneVittoria == 0 || condizioneVittoria == 1 || condizioneVittoria == 2 {
            //Si resetta il valore iniziale della condizione di vittoria
            autolock = true
            
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
    
    func setViewModel(viewModel: ViewModel ){
        
        self.viewModel = viewModel
        
        self.simulation = SimulazionePesce(viewModel: viewModel)
//        self.simulation = SimulazionePesce()
    }
    
}
