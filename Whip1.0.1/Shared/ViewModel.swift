//
//  ViewModel.swift
//  Vibrations
//
//  Created by Antonio Tridente on 11/03/24.
//

//SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true)

import Foundation
import Combine

var variableTest = 1

// MARK: - Value
struct Value: Codable {
    let path: String
    let value: Int
}

class ViewModel: ObservableObject{
    
    private var connectivityProvider: ConnectivityProvider
    
    @Published var scrollspeed: Int = 0
    @Published var acceleation: Int = 0
    @Published var maxAcceleration: Int = 0
    @Published var deltaY: Int = 0
    @Published var deltaX: Int = 0
    @Published var deltaZ: Int = 0
    
    @Published var trow: Int = 0
    
    @Published var avanti: Int = 0
    @Published var fineSimulazione: Int = -1
    @Published var inizioSimulazione: Int = -1
    @Published var canTrow: Int = 0
    @Published var canTrowRecieved: Int = 0
    @Published var canTrowSecondSignal: Int = 0
    @Published var canTrowSecondSignalRecieved: Int = 0
    @Published var cannotTrow: Int = 0
    @Published var vittoria: Int = 0
    
    @Published var pesca: Int = 0
    @Published var pescaRecieved: Int = 0
    @Published var frDurability: Int = 100
    
    @Published var connected: Bool = false
    @Published var showProgressBar = false
    
    @Published var trowSignalRecieved = 0
    @Published var startSimulationRecieved = 0
    @Published var fishWentAway = 0
    
    @Published var typeSpawned = -1
    @Published var choosedRarity = -1
    
    @Published var canSpawnPopup = 0
    
    @Published var awakeSignal = -1
    @Published var trowBait = -1
    
    #if os(iOS)
    @Published var recievedSecond = -1
    #endif
    
    
    
    
    var valueModel: PassthroughSubject<Value, Never> = PassthroughSubject<Value, Never>()
    var requests: AnyCancellable?
    
    init (){
        
        self.connectivityProvider = ConnectivityProvider(modelUpdates: valueModel)
        self.connectivityProvider.connect()
        
        requests = valueModel.sink(receiveValue: {
            value in
            switch value.path{
            case "scrollSpeed":
                self.scrollspeed = value.value
            case "acceleration":
                self.acceleation = value.value
            case "deltaY":
                self.deltaY = value.value
            case "deltaX":
                self.deltaX = value.value
            case "deltaZ":
                self.deltaZ = value.value
                
            case "trow":
                self.trow = value.value
                
            case "canTrow":
                self.canTrow = value.value
            case "canTrowRecieved":
                self.canTrowRecieved = value.value
            case "canTrowSecondSignal":
                self.canTrowSecondSignal = value.value
            case "canTrowSecondSignalRecieved":
                self.canTrowSecondSignalRecieved = value.value
            case "cannotTrow":
                self.cannotTrow = value.value
                
            case "maxAcceleration":
                self.maxAcceleration = value.value
            case "Avanti":
                self.avanti = value.value
            case "FineSimulazione":
                self.fineSimulazione = value.value
            case "InizioSimulazione":
                self.inizioSimulazione = value.value
            case "Vittoria":
                self.vittoria = value.value
            case "Pesca":
                self.pesca = value.value
            case "pescaRecieved":
                self.pescaRecieved = value.value
                
            case "frDurability":
                self.frDurability = value.value
            case "trowSignalRecieved":
                self.trowSignalRecieved = value.value
            case "startSimulationRecieved":
                self.startSimulationRecieved = value.value
            case "fishWentAway":
                self.fishWentAway = value.value
                 
            case "TypeSpawned":
                self.typeSpawned = value.value
            case "ChoosedRarity":
                self.choosedRarity = value.value
                
            case "canSpawnPopup":
                self.canSpawnPopup = value.value
                
            case "AwakeSignal":
                self.awakeSignal = value.value
            case "trowBait":
                self.trowBait = value.value
                
            case "sendedSeconds":
                #if os(iOS)
                self.recievedSecond = value.value
                #else
                _ = value.value
                #endif
                
            default:
                print("Error. Path = \(value.path). Value = \(value.value)")
                // Creo una variabile locale che svuota l'attuale valore in modo da pulire il processi di sink
                _ = value.value
            }
        })
        
    }
    
    func sendMessage(key: String, value: Any){
        let message = ["path": key, "value": value]
        connectivityProvider.send(message: message)
    }
    // Aggiungi questo metodo nella classe ViewModel
    
    func updateConnection(){
        
        if connectivityProvider.connectionEstablished {
            connected = true
        } else {
            connected = false
        }
        
    }



    
    
}
