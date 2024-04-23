//
//  LatencyModuler.swift
//  WhIP
//
//  Created by Antonio Tridente on 18/04/24.
//

import Foundation
import SpriteKit

class LatencyModuler{
    
    // Il viewModel è uguale per entrambi i dispositivi
    private var viewModel: ViewModel!
    
    // Per iphone vengono dichiarate più variabili ed un costruttore apposito
    // Che richieda anche una scena in ingresso per poterla modificare
    #if os(iOS)
    private var savedSeconds = -1
    private var recievedSeconds = 0
    private var latency = 0
    
    private var scene: SKScriptIphone!
    
    private var latencyNode = SKSpriteNode()
    let moveUP = SKAction.moveTo(y: 614, duration: 0.6)
    let moveCenter = SKAction.moveTo(y: 551, duration: 0.6)
    let moveDown = SKAction.moveTo(y: 470, duration: 0.6)
    
    // Questa variabile serve ad indicare se il watch si è disconnesso
    private var watchDisconnected: Bool = false
    
    init(scene: SKScriptIphone, viewModel: ViewModel) {
        self.viewModel = viewModel
        self.scene = scene
        self.latencyNode = scene.childNode(withName: "latencyNode") as! SKSpriteNode
        self.latencyNode.texture = SKTexture(imageNamed: "signal0")
        // Viene attivata la possibilità di rivecere ed inviare messaggi
        recieveCurrentTime()
        // La funzione sendCurrent time in realtà salva solo i secondi correnti in base all'ora
        // Soltanto nel watch viene inviato un segnale
        sendCurrentTime()
        
    }
    
    private func recieveCurrentTime(){
    
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true){ _ in
            
            // Ogni secondo andiamo a controllare la differenza tra i due valori
            // Quello registrato localmente e quello ricevuto
            
            // Se il watch smette di inviare segnali il recievedSecond del viewModel
            // è uguale a quello registrato localmente, pertanto viene segnalato
            if self.recievedSeconds == self.viewModel.recievedSecond {
                self.watchDisconnected = true
            // Altrimenti si esegue il normale algoritmo andando ad assegnare il nuovo valore
            } else {
                self.recievedSeconds = self.viewModel.recievedSecond
                self.watchDisconnected = false
            }
            
            // Se arriva un numero più bassi di quello corrente significa che un
            // minuto è trascorso e che il ciclo di interi tra 0 e 59 nel watch è
            // ricominciato
            if self.recievedSeconds < self.savedSeconds {
                //Andiamo quindi a calcolare la latenza in modo diverso
                // Trovando prima la differenza dal 59esimo secondo
                let complementaryDifference = 59 - self.savedSeconds
                // e poi aggiungendola ai secondi ricevuti
                self.latency = complementaryDifference + self.recievedSeconds
                self.updateSignal()
            // In tutti gli altri casi i secondi erano maggiori e quindi
            // Si calcola la differenza semplice tra i secondi salvati e quelli ricevuti
            } else {
                self.latency = self.recievedSeconds - self.savedSeconds
                self.updateSignal()
            }
            
            // Ad ogni modo i secondi correnti vengono salvati come i secondi ricevuti
            self.savedSeconds = self.recievedSeconds
            
            print("Latency: \(self.latency)")
        }
        
    
    }
    
    // Questa funzione serve a definire gli sprite assegnati all'icona della connessione
    // Per indicare all'utente la qualità del segnale
    private func updateSignal(){
    
        // Se i secondi ricevuti sono ancora a -1
        // Vuol dire che il watch non si è ancora connesso
        if self.viewModel.recievedSecond < 0 {
            self.latencyNode.texture = SKTexture(imageNamed: "signal0")
            print("Set Signal to Disconnected")
        // Altrimenti vengono gestiti 3 casi principali
        // Se la latenza è 0 oppure 1 viene mostrata l'icona verde
        } else if self.latency <= 1 {
            self.latencyNode.texture = SKTexture(imageNamed: "signal3")
            print("Set Signal to Green")
        // tra 2 e 3 una icona arancione
        } else if self.latency <= 3 {
            self.latencyNode.texture = SKTexture(imageNamed: "signal2")
            print("Set Signal to Orange")
        // e maggiore di 3 una icona rossa
        } else if self.latency > 3 {
            self.latencyNode.texture = SKTexture(imageNamed: "signal1")
            print("Set Signal to Red")
        }
            
        // Se il watch si è disconnesso, viene segnalato
        if self.watchDisconnected {
            self.latencyNode.texture = SKTexture(imageNamed: "signal0")
            print("Set Signal to Disconnected")
        }
            
        print("Latency: \(self.latency).\nSaved sconds: \(self.savedSeconds).\nRecieved seconds: \(self.recievedSeconds)")
        
        
    }

    
    #endif
    
    // Questo inizializzatore è disponibile solo per apple watch, e richiede solo un view model per
    // L'invio dei segnali
    #if os(watchOS)
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        sendCurrentTime()
    }
    #endif
    
    
    // Questa è una funzione che è disponibile ad entrambi i dispositivi ed è
    // Strutturata per funzionare in modo singolare in base al dispositivo
    func sendCurrentTime(){
        
        // in amiente ios viene vengono solo salvati i secondi
        #if os(iOS)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true){ _ in
            // Salviamo ogni secondo l'attuale tempo e lo registriamo localmente
            self.savedSeconds = Calendar.current.component(.second, from: Date())
        }
        #endif
        
        // in ambiente watchOS vengono soltanto inviati i secondi correnti
        #if os(watchOS)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true){ _ in
            // Mandiamo ogni secondo l'attuale tempo in secondi all'iphone
            let seconds = Calendar.current.component(.second, from: Date())
            self.viewModel.sendMessage(key: "sendedSeconds", value: seconds)
            
        }
        #endif
    }
    
    // Questa due funzioni seguenti invece servono a muovere il segnale
    //in posti divrsi ai fini di una buona leggibilità della GUI
    func moveSignalUP(){
        #if os(iOS)
        self.latencyNode.run(self.moveUP)
        #endif
    }
    
    func moveSignalCenter(){
        #if os(iOS)
        self.latencyNode.run(self.moveCenter)
        #endif
    }
    
    func moveSignalDown(){
        #if os(iOS)
        self.latencyNode.run(self.moveDown)
        #endif
    }
    
    
    
}
