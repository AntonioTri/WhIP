
import SpriteKit
import Foundation
import SwiftUI
import AVFoundation




class SKScriptIphone: SKScene, SKPhysicsContactDelegate {
    
    // Nodi di BackEnd
    var barraOrizzontale = SKSpriteNode()
    var galleggiante = SKSpriteNode()
    var barra = SKSpriteNode()
    var fishingRod = SKSpriteNode()
    var fishingRodAttachPoint = SKSpriteNode()
    var progressionBar = SKSpriteNode()
    var semafero = SKSpriteNode()
    
    //Variabili per i nodi del menù
    var menu = SKSpriteNode()
    var playButton = SKSpriteNode()
    var howToPlay = SKSpriteNode()
    var istruzioni = SKSpriteNode()
    var instagramButton = SKSpriteNode()
    var back = SKSpriteNode()
    var mainMenu = SKSpriteNode()
    
    //Nodi e texture di ambiente
    var backgroundTextures = [SKTexture]()
    var baitTextures = [SKTexture]()
    var backgroundNode: SKSpriteNode!
    
    //Animazioni canna da pesca e backGround
    var backGroundAnimation = SKAction()
    var landingBaitAnimation = SKAction()
    var wigglingBaitAnimation = SKAction()
    var baitBeeingTrown = SKAction()
    var baitGroupAnimation = SKAction()
    var infiniteBaitingAnimation = SKAction()
    var infiniteBaitIdle = SKAction()
    
    // Animaizone vittoria del pesce 1
    var infiniteFish1Animation = SKAction()
    var infiniteFish2Animation = SKAction()
    var trowingPT2 = SKAction()
    var youCanWhip = SKAction()
    
    // Animazioni di lancio
    var trowingFishingRod = SKAction()
    var pullingFishingRod = SKAction()
    var infiniteIdleAnimation = SKAction()
    
    // Queste azioni ci permettono di far comparire e scomparire elementi dallo schermo
    var fadeIn = SKAction()
    var fadeOut = SKAction()
    
    var oldLine = SKShapeNode()
    
    var backGroundAmbiance = SKAction()
    var baitingSound = SKAction()
    var fishingRodCast = SKAction()
    var breakingRope = SKAction()

    
    let velocitaOrizontale = -155.0
    let velocitaVerticale = Double.random(in: 1...100)
    var autolockBG = true
    
    var showProgressBar = false
    var showRope = false
    var baiting = false
    var canSpawnFly = false
    var fishPullingRope = false
    
    var canPressMainMenu = false
    var setSemaferoGreen = false
    var setSemaferoRed = false
    var menuOpen = true
    var timer: Timer?
    
    var autolockLancio = true
    var autolockPesca = true
    var autolockRotturaLenza = true
    var autolockVittoria = true
    var autolockPerdita = true
    var autolockAtterraggio = true
    var autolockPB = true
    var contactCount = 0
    
    var autolockBlinking = true

    var fishingProgress = 0.0
    
    var viewModel: ViewModel!
    var blinkingSignal: BlinkingRedSignal!
    var latencyModuler: LatencyModuler!
    var savingCenter = SavingsCenter()
    let tableGenerator = TableGenerator()
    
   
    var fish: Fish!
    var fishCollection: FishCollection!
    var commonFishGUI: CommonFishesGUI!
    var backGround: BackGround!
    var fly: Fly!
    var currentTable: [[Int]] = []
    var currentState = 0
    
    override func didMove(to view: SKView) {
        self.inizialize()

    }

    var test = true
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let position = touch!.location(in: self)
        let currentNode = self.atPoint(position) as? SKSpriteNode
       
        // Viene inviato il tocco anche alla GUI dei pesci
        self.commonFishGUI.checkXButtonPressed(touchedNode: currentNode ?? SKSpriteNode())
        // Si manda il tocco sullo schermo al menù dei collezionabili
        self.fishCollection.scrollPage(touch: touch!)
        
        if currentNode == self.playButton {
            
            self.playButton.run(SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true))
            
            if hourChanged(){
                print("L'ora è cambiata. Mostro la gui dei pesci giornalieri")
                self.commonFishGUI.showUp(table: self.currentTable)
            } else {
                print("L'ora non è cambiata. Mostro direttamente la gaming Scene")
                self.showGamingScene()
            }
            
            self.menu.run(SKAction.group([SKAction.moveTo(y: 2000, duration: 0.8), fadeOut]))
            
            self.currentState = 1
        }
    
        if currentNode == self.howToPlay{
            
            self.howToPlay.run(SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true))
            self.menu.run(SKAction.group([SKAction.moveTo(x: -1600, duration: 0.8), fadeOut]) )
            self.istruzioni.run(SKAction.group([SKAction.moveTo(x: 0, duration: 0.8), fadeIn]))
            self.latencyModuler.moveSignalUP()
            self.viewModel.sendMessage(key: "cannotTrow", value: 1)
            
        }
            
        if currentNode == self.back {
            
            self.back.run(SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true))
            self.istruzioni.run(SKAction.group([SKAction.moveTo(x: 1600, duration: 0.8), fadeOut]))
            self.menu.run(SKAction.group([SKAction.moveTo(x: 13.842, duration: 0.8), fadeIn]) )
            self.latencyModuler.moveSignalCenter()
                
        }
        
        if currentNode == self.instagramButton {
            let pagInsta = URL(string: "https://www.instagram.com/whip_fishing")!
            UIApplication.shared.open(pagInsta)
        }
        
        if currentNode == self.mainMenu && self.canPressMainMenu {
            
            self.hideGamingScene()
            self.latencyModuler.moveSignalCenter()
            self.viewModel.sendMessage(key: "cannotTrow", value: 1)
            self.menu.run(SKAction.group([SKAction.moveTo(y: 347, duration: 1), fadeIn]))
            self.currentState = 0
            
        }
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Controllo sui corpi collisi, se sono barra e galleggiante viene inviato il segnale di inizio simulazione
        let sum = (contact.bodyA.node?.physicsBody?.collisionBitMask)! + (contact.bodyB.node?.physicsBody?.collisionBitMask)!
        
        contactCount += 1
        print("Contatore Contatti = \(contactCount)")
        //Se la somma è 3 l'amo è atterrato sull'acqua e viene inviato il segnale
        if sum == UInt32(3) && autolockAtterraggio && contactCount >= 2{
           
            print("Invio il segnale di inizio simulazione")
            
            viewModel.sendMessage(key: "InizioSimulazione", value: 1)
            viewModel.trow = 0
            viewModel.sendMessage(key: "trow", value: 0)
            contactCount = 0
            // Segnale di kill nel caso il watch abbia resettato i suoi timer interni
            self.viewModel.sendMessage(key: "cannotTrow", value: 1)
            autolockAtterraggio = false
            galleggiante.run(baitGroupAnimation)
            galleggiante.run(SKAction.playSoundFileNamed("baitLandins", waitForCompletion: true))
            
            // viene scelto il pesce da simulare
            self.chooseFish()
            
            // Questo controllo serve per controllare ciclicamente che il segnale di inizio simulazione sia arrivato
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true){ timer in
                
                // Se questo non è arrivato viene inviato nuovamente il segnale
                if self.viewModel.startSimulationRecieved == 0 {
                    self.viewModel.sendMessage(key: "InizioSimulazione", value: 1)
                    self.chooseFish()
                // Altrimenti si invalida il timer e si riposta la variabile del segnale a 0 localmente
                } else {
                    self.viewModel.startSimulationRecieved = 0
                    timer.invalidate()
                }
                
            }
            
        } else if contactCount == 1 {
            
            galleggiante.run(infiniteBaitIdle)
            
        }
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        
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
        
        // Si gestiscono gli eventi per scacciare le mosche
        if viewModel.trowBait == 1 && self.fly.getFlyIsSpawned() {
            viewModel.trowBait = 0
            print("Scaccio la mosca")
            self.fly.setFlyGoAway()
        } else if viewModel.trowBait == 1 {
            viewModel.trowBait = 0
        }
        
        // Si mostrano i popup verdi per la cura della lenza
        if self.viewModel.canSpawnPopup == 1{
            self.viewModel.canSpawnPopup = 0
            _ = HealtPopups(scene: self)
        }
        
        // Si gestisce la pulsazione del segnale di pericolo
        // Con i seguenti due if
        if viewModel.frDurability < 35 && autolockBlinking {
            self.autolockBlinking = false
            self.blinkingSignal.startBlinking()
        }
        if viewModel.frDurability > 50 && !autolockBlinking {
            self.autolockBlinking = true
            self.blinkingSignal.stopBlinking()
        }
        
        // Disegnamo la lenza se ci troviamo nel giusto frame di animazione
        if self.showRope {
            drawLine(x: fishingRodAttachPoint.position.x, y: fishingRodAttachPoint.position.y, galleggiante: galleggiante.position)
        }
        
        // Viene mostrata la barra di progressione se il pesce sta tirando
        if self.showProgressBar {
            updateProgressionBar()
        }
        
        // Controllo per osservare se sia stato eseguito un lancio
        if viewModel.trow == 1 && autolockLancio && !self.menuOpen && self.currentState == 1{
            // Script per eseguire il lancio
            self.trowAnimation()
        }
        
        // Controlli per vedere la fine della simulazione ed eseguire l'animazione adatta
        if viewModel.fineSimulazione == 0 && autolockVittoria {
            // Viene eseguito lo script per la vittoria
            self.victoryAnimation()
            
        } else if viewModel.fineSimulazione == 1 && autolockPerdita {
            // Viene eseguito lo script per la lose
            self.loseAnimation()
            
        } else if viewModel.fineSimulazione == 2 && autolockRotturaLenza {
            // Viene eseguito lo script per la rpttura lenza
            self.brokenRopeAnimation()
        }
        
        if viewModel.fishWentAway == 1 {
            print("E' arrivato il segnale del pesce che scappa, spawno un nuovo pesce ed invio i segnali")
            viewModel.fishWentAway = 0
            viewModel.sendMessage(key: "InizioSimulazione", value: 1)
            self.chooseFish()
        }
        
        // Controllo per osservare se il pesce ha abboccato
        if viewModel.pesca == 1 && autolockPB {
            //Segnale di ackNowledgement
            self.viewModel.sendMessage(key: "pescaRecieved", value: 1)
            // Viene eseguito lo script per quando il pesce abbocca
            self.fishBaitedAnimation()
        }
        
    }

    private func setPesca(){
        //si inizializzano le variabili per la pesca
        viewModel.pesca = 0
        viewModel.sendMessage(key: "Pesca", value: 0)
        viewModel.showProgressBar = true
        galleggiante.removeAllActions()
        
    }
    

    // Questa funzione inizializza la tavola dei valori contenente tutte le tuple possibili
    // La flag TABLE_GENERATED salvata nel database ci aiuta a generare la tavola una sola volta
    // andandola a salvare poi nel database ed autobloccandosi impostanto la TABLE_GENERATED a true
    private func initializeTable(){
        
        // Si controlla la flag
        if !savingCenter.getSavedBool(key: savingCenter.TABLE_GENERATED) {
            
            print("Genero le tuple per la prima volta")
            // Si segnala che la tavola è stata generata
            savingCenter.saveBool(dataToSave: true, key: savingCenter.TABLE_GENERATED)
            // Si genera la tavola dei valori, la stessa funzione si occupa di salvarla
            tableGenerator.generateTable()
            
        } else {
            print("Ho già generato e salvato le tuple. Non ne genero di nuove.")
        }
        
        // Viene in tutti i casi, generata una tavola corrente, che sulla base del seed giornaliero,
        // Cambia le percentuali di rarità di ogni pesce
        self.currentTable = tableGenerator.generateCurrentTable()
        
        
    }

    private func resetThings() { 
        
        print("Resetto le cose")
        viewModel.fineSimulazione = -1
        viewModel.sendMessage(key: "FineSimulazione", value: -1)
        self.blinkingSignal.stopBlinking()
        // Si eseguono dei reset in modo dilaizonato, operazioni delicate che hanno a che fare
        // con la connectivity e la possibilità di premere dei bottoni nella scena
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){ _ in
            
            self.autolockLancio = true
            self.viewModel.sendMessage(key: "canTrow", value: 1)
            // Viene inviato un secondo segnale per dare tempo al watch di resettare i suoi dati interni
            // Prima di riprendere con l'ascolto dei movimenti tramite il giroscopio
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
                print("Invio il secondo segnale di can Trow")
                self.viewModel.sendMessage(key: "canTrowSecondSignal", value: 1)
                self.setSemaferoGreen = true
                self.fishCollection.showCollectionbutton()
                self.latencyModuler.moveSignalDown()
                // Faccio ricomparire il botone per tornare al menù
                self.canPressMainMenu = true
                self.mainMenu.run(self.fadeIn)
            }
            
        }
        
        // Si porta il valore della vittoria conservato nel viewModel a 400
        viewModel.vittoria = 400
        // reset dell'autolock sulla animazione di bait
        self.autolockPB = true
        // Si nasconde la progress bar
        self.showProgressBar = false
        // Si nasconde la'amo da pesca e si pulisce l'ultima lenza disegnata
        self.showRope = false
        self.fishPullingRope = false
        oldLine.removeFromParent()
        
        // Si resettano le posizioni e le animazioni
        self.galleggiante.position.x = CGFloat(1120)
        self.galleggiante.position.y = CGFloat(120)
        self.galleggiante.size = CGSize(width: CGFloat(126.237), height: CGFloat(167.883))
        self.galleggiante.removeAllActions()
        
        self.barraOrizzontale.position.x = CGFloat(274.7510070800781)
        self.barraOrizzontale.position.y = CGFloat(-18.364999771118164)
        
        self.fishingRod.removeAllActions()
        self.fishingRodAttachPoint.position = CGPoint(x: 200, y: 586.41)
        self.fishingRod.run(infiniteIdleAnimation)
        
    }

    
    // Funzione che gestisce la vittoria
    private func victoryAnimation(){
        print("Animazione vittoria")
        self.fishingRod.removeAllActions()
        self.fishingRodAttachPoint.removeAllActions()
        self.progressionBar.run(fadeOut)
        // Viene mostrata l'animazione del trofeo corrispondente al tipo e rarità di pesce spawnato
        // All'intreno del metodo viene anche aggiornato il catalogo
        self.fish.setNewInternalState(typeSpawned: viewModel.typeSpawned , raritySpawned: viewModel.choosedRarity)
        self.showFish()
        self.galleggiante.alpha = 0
        self.showRope = false
        self.oldLine.removeFromParent()
        self.autolockVittoria = false
        self.canSpawnFly = false
        self.blinkingSignal.stopBlinking()
        // Dopo un breve lasso di tempo si resetta il trofeo in basso e si resetta la scena
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false){ _ in
            self.resetThings()
        }
    }
    
    // Funzione che gestisce la sconfitta
    private func loseAnimation(){
        print("Animazione Sconfitta")
        self.fishingRod.run(self.breakingRope)
        self.fishingRodAttachPoint.removeAllActions()
        self.galleggiante.alpha = 0
        self.showRope = false
        self.oldLine.removeFromParent()
        self.canSpawnFly = false
        self.progressionBar.run(fadeOut)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false){ _ in
            self.resetThings()
        }
        self.autolockPerdita = false
        
    }
    
    // Funzione che gestisce la rottura lenza
    private func brokenRopeAnimation(){
        print("Animazione Rottura lenza")
        self.fishingRod.run(self.breakingRope)
        self.fishingRodAttachPoint.removeAllActions()
        self.galleggiante.alpha = 0
        self.showRope = false
        self.oldLine.removeFromParent()
        self.canSpawnFly = false
        self.progressionBar.run(fadeOut)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false){ _ in
            self.resetThings()
        }
        self.autolockRotturaLenza = false
        
    }
    
    // funzione che gestisce lo script per quando il pesce abbocca
    private func fishBaitedAnimation(){
        
        print("Segnale di baiting arrivato")
        autolockPB = false
        self.showProgressBar = true
        self.setPesca()
        
        //Si nasconde la lenza curva e si mostra quella diritta
        self.baiting = false
        self.fishPullingRope = true
        
        // Si blocca anche la possibilità di spawnarne di nuove
        // Oltre che scacciare la mosca corrente se presente
        self.fly.stopSpawningMoreFlyes()
        
        // Eseguo una nuova animazione per il galleggiante
        progressionBar.run(fadeIn)
        galleggiante.run(infiniteBaitingAnimation)
        fishingRod.run(pullingFishingRod)
        // Viene eseguito il suono di baiting
        fishingRodAttachPoint.run(baitingSound)
        fishingRodAttachPoint.position = CGPoint(x: 207.759, y: 514.982)
        
    }
    
    // Funzione che gestisce il lancio della canna da pesca
    private func trowAnimation(){
        
        // Viene segnalato che il segnale di lancio è arrivato
        viewModel.sendMessage(key: "trowSignalRecieved", value: 1)
        viewModel.trowSignalRecieved = 0
        
        // Nascondo i vari bottoni e gui varie
        self.mainMenu.run(fadeOut)
        self.setSemaferoRed = true
        self.canPressMainMenu = false
        self.fishCollection.hideCollectionButton()
        
        // Si resettano gli autolock
        autolockLancio = false
        autolockAtterraggio = true
        
        // Si mostra la lenza
        self.baiting = true
        
        // Inizia a spawnare le mosche
        self.fly.startSpawningFlyes()
        
        // Si sposta in alto il segnale di connessione
        self.latencyModuler.moveSignalUP()
        
        // Vì Viene eseguita l'animazione del lancio
        print("Animazine lancio")
        self.fishingRod.run(trowingFishingRod)
        self.fishingRod.run(fishingRodCast)
    
    }
    
    // Questa funzione sceglie il pesce da simulare
    private func chooseFish(){
        
        // Si seleziona uno tra i 10 pesci disponibili per la giornata
        let type = self.avayableFish()
        // Si estrae la sua riga di rarità dalla tabella dei valori attuali
        let probability = currentTable[type]
        // si sceglie la rarità sulla base delle probabilità
        let choosedRarity = self.choosenRarity(probability: probability)
        
        // Vengono poi inviate queste informazioni al watch che si occuperà della simulazione
        viewModel.sendMessage(key: "TypeSpawned", value: type)
        viewModel.sendMessage(key: "ChoosedRarity", value: choosedRarity)
        viewModel.typeSpawned = type
        viewModel.choosedRarity = choosedRarity
    
    }
    
    
    // Questa funzione sceglie di che rarità deve essere il pesce generato
    private func choosenRarity(probability: [Int]) -> Int{
        
        // Si estraggono le rarità in ingresso
        let common = probability[0]
        let rare = probability[1]
        let epic = probability[2]
        let legendary = probability[3]
        
        print("Common: \(common)")
        print("Rare: \(rare)")
        print("Epic: \(epic)")
        print("Legendary: \(legendary)")
        
        // Si gestiscono e si creano gli intervalli di probabilità
        let commonUpperLimit = common
        let rareLowerLimit = common + 1
        let rareUpperLimit = common + rare
        let epicLowerLimit = common + rare + 1
        let epicUpperLimit = common + rare + epic
        let legendaryLowerLimit = common + rare + epic + 1
        
        // Si genera un numero casuale ...
        let rand = Int.random(in: 1...100)
        var choosedRarity: Int = 0
        
        // ... e si controlla in che intervallo di rarità si trova
        // andando a settare il giusto valore alla rarità
        if rand <= commonUpperLimit {
            choosedRarity = 0
        } else if rand >= rareLowerLimit && rand <= rareUpperLimit {
            choosedRarity = 1
        } else if rand >= epicLowerLimit && rand <= epicUpperLimit {
            choosedRarity = 2
        } else if rand >= legendaryLowerLimit && rand <= 100 {
            choosedRarity = 3
        }
        
        // viene ritornata la rarità così generata
        return choosedRarity
    }
    
    //La funzione che restituisce un intero rappresentante uno dei pesci disponibili in giornata
    private func avayableFish() -> Int{
        return Int.random(in: 0...8)
    }
    
    // Funzione che mostra il pesce pescato, sia sulla canna da pesca che come trofeo
    private func showFish(){

        let texture1 = SKTexture(imageNamed: "pullingUp-\(viewModel.typeSpawned)-1")
        let texture2 = SKTexture(imageNamed: "pullingUp-\(viewModel.typeSpawned)-2")
        let texture3 = SKTexture(imageNamed: "pullingUp-\(viewModel.typeSpawned)-3")
        
        let anim1 = SKAction.animate(with: [texture1, texture2, texture3], timePerFrame: 0.2)
        
        let pullingUpAnimation = SKAction.sequence([anim1, self.trowingPT2])
        self.fishingRod.run(pullingUpAnimation)
        
    }
    
    private func movimentoAmoAlLancio () {
        
        self.galleggiante.alpha = 1
        self.galleggiante.physicsBody?.applyImpulse(CGVector(dx: velocitaOrizontale - Double(Int.random(in: 60...100)), dy: velocitaVerticale + 500))
        
        let action = SKAction.scale(by: Double.random(in: 0.5...0.7), duration: 1)
        self.galleggiante.run(action)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.barraOrizzontale.position.y = CGFloat(Int.random(in: 161...280))
            
        }
        
    }
    
    // Funzione che mi permette di disegnare la lenza
    private func drawLine(x: Double, y: Double, galleggiante: CGPoint){
        
        if self.baiting {
            self.drawParabolas(x: x, y: y, galleggiante: galleggiante)
        } else if self.fishPullingRope {
            self.drawStraightLine(x: x, y: y, galleggiante: galleggiante)
        }
        
        
    }
    
    // Disegno della lenza diritta
    private func drawStraightLine(x: Double, y: Double, galleggiante: CGPoint){
        
        let yourLine = SKShapeNode()
        let pathToDraw = CGMutablePath()
        
        oldLine.removeFromParent()
        
        pathToDraw.move(to: CGPoint(x: x, y: y))
        pathToDraw.addLine(to: galleggiante)
        yourLine.path = pathToDraw
        
        //Si setta il colore del filo sulla base della durabilità
        yourLine.strokeColor = self.colorFromValue(CGFloat(viewModel.frDurability))
        yourLine.zPosition = 4
        
        addChild(yourLine)
        oldLine = yourLine
        
    }
    
    // Disegno della lenza curva
    private func drawParabolas(x: Double, y: Double, galleggiante: CGPoint){
        
        var yourLine = SKShapeNode()
        let pathToDraw = CGMutablePath()
        
        oldLine.removeFromParent()
        
        let pointA = CGPoint(x: galleggiante.x, y: galleggiante.y)
        let pointB = CGPoint(x: x, y: y)
        let controlPoint = CGPoint(x: (pointA.x + pointB.x) / 2, y: pointA.y - (pointB.y - pointA.y) * 0.1)
        
        pathToDraw.move(to: pointA)
        pathToDraw.addQuadCurve(to: pointB, control: controlPoint)
        yourLine = SKShapeNode(path: pathToDraw)
        
        //Si setta il colore del filo sulla base della durabilità
        yourLine.strokeColor = self.colorFromValue(CGFloat(viewModel.frDurability))
        yourLine.zPosition = 4
        
        addChild(yourLine)
        oldLine = yourLine
    }
    
    //Questa funzione serve a capire se l'ora è cambiata
    private func hourChanged() -> Bool{
        
        let currentHour = findHour()
        let savedHour = savingCenter.getSavedInteger(key: savingCenter.SKSCRIPT_HOUR_SAVED)
        
        if currentHour != savedHour {
            savingCenter.saveInteger(dataToSave: currentHour, key: savingCenter.SKSCRIPT_HOUR_SAVED)
            return true
        }
        
        return false
    }
    
    // Questa funzione serve a normalizzare il valore dell'ora per indicare 3 fasce orarie specifiche
    // 0 indica il giorno, 1 il pomeriggio e 2 sera e notte
    func findHour() -> Int {
     
        var hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 9 && hour < 15 {
            hour = 0
        } else if hour >= 15 && hour < 21 {
            hour = 1
        } else if (hour >= 21 && hour <= 24) || (hour > 0 && hour < 9) {
            hour = 2
        }
        
        return hour
    }
    
    //Questa funzione genera il colore della lenza sulla base della sua durabilità
    private func colorFromValue(_ value: CGFloat) -> UIColor {
        // Calcolo la componente rossa del colore
        let rosso = 1.0
        // Calcolo la componente verde del colore
        let verde = value / 100
        // Calcolo la componente blu del colore
        let blu = value / 100
        
        if viewModel.frDurability < 45 {
            self.showTutorial()
        }
        
        return UIColor(red: rosso, green: verde, blue: blu, alpha: 1.0)
    }
    
    // Questa funzione cambia il colore alla barra di progressione
    // sulla base del valore del viewModel
    private func progressionBarColor(_ value: CGFloat) -> UIColor{
        
        // Creiamo le componenti sulla base del viewModel
        let red = value / 800
        let green = 1 - (value / 800)
        
        return UIColor(red: red, green: green, blue: 0.25, alpha: 1)
    }
    
    //Questa funzione modifica la lunghezza ed il colore della barra di progressione
    private func updateProgressionBar() {
        //Viene reso dinamico il size della barra
        self.progressionBar.size.width = CGFloat(950 - (( 950 * viewModel.vittoria) / 800))
        // Viene cambiato il colore sulla base della vittoria
        self.progressionBar.color = self.progressionBarColor(CGFloat(viewModel.vittoria))
    }

    private func resetBools(){
        autolockPerdita = true
        autolockVittoria = true
        autolockRotturaLenza = true
    }
    
    private func inizialize(){
        
        physicsWorld.contactDelegate = self
        self.barraOrizzontale = childNode(withName: "BarraOrizzontale") as! SKSpriteNode
        self.galleggiante = childNode(withName: "Galleggiante") as! SKSpriteNode
        self.fishingRod = childNode(withName: "fishingRod") as! SKSpriteNode
        self.progressionBar = childNode(withName: "progressionBar") as! SKSpriteNode
        self.fishingRodAttachPoint = childNode(withName: "FRAttachPoint") as! SKSpriteNode
        
        self.menu = childNode(withName: "Menu") as! SKSpriteNode
        self.playButton = menu.childNode(withName: "Play") as! SKSpriteNode
        self.howToPlay = menu.childNode(withName: "HowToPlay") as! SKSpriteNode
        self.instagramButton = menu.childNode(withName: "instagramButton") as! SKSpriteNode
        
        self.istruzioni = childNode(withName: "istruzioni") as! SKSpriteNode
        self.back = istruzioni.childNode(withName: "back") as! SKSpriteNode
        self.mainMenu = childNode(withName: "MainMenu") as! SKSpriteNode
        
        self.semafero = childNode(withName: "youCanWhip") as! SKSpriteNode
        self.semafero.zPosition = 20
        self.semafero.alpha = 0
        
        barraOrizzontale.alpha = 0
        progressionBar.alpha = 0
        fishingRod.alpha = 0
        
        //Baiting
        let baitingSnd = SKAction.playSoundFileNamed("baitingSound", waitForCompletion: true)
        baitingSound = SKAction.repeatForever(baitingSnd)
        
        //Fishing rod cast
        fishingRodCast = SKAction.playSoundFileNamed("frCast", waitForCompletion: true)
        
        //Sprite del galleggiante
        let gall1 = SKTexture(imageNamed: "galleggiante1")
        let gall2 = SKTexture(imageNamed: "galleggiante2")
        let gall3 = SKTexture(imageNamed: "galleggiante3")
        let gall4 = SKTexture(imageNamed: "galleggiante4")
        let gall5 = SKTexture(imageNamed: "galleggiante5")
        let gall6 = SKTexture(imageNamed: "galleggiante6")
        
        //Sprite della canna da pesca
        let fishingRod1 = SKTexture(imageNamed: "cdp1")
        let fishingRod2 = SKTexture(imageNamed: "cdp2")
        let fishingRod3 = SKTexture(imageNamed: "cdp3")
        let fishingRod4 = SKTexture(imageNamed: "cdp4")
        let fishingRod5 = SKTexture(imageNamed: "cdp5")
        let fishingRod6 = SKTexture(imageNamed: "cdp6")
        let fishingRod7 = SKTexture(imageNamed: "cdp7")
        let fishingRod8 = SKTexture(imageNamed: "cdp8")
        let fishingRod9 = SKTexture(imageNamed: "cdp9")
        let fishingRod10 = SKTexture(imageNamed: "cdp10")
        let fishingRod11 = SKTexture(imageNamed: "cpd11")
        
        //Sprite dei trofei dei pesci
        let fish11 = SKTexture(imageNamed: "fish11")
        let fish12 = SKTexture(imageNamed: "fish12")
        let fish21 = SKTexture(imageNamed: "fish21")
        let fish22 = SKTexture(imageNamed: "fish22")
        
        let canWhip1 = SKTexture(imageNamed: "canWhip1")
        let canWhip2 = SKTexture(imageNamed: "canWhip2")
        
        let breaking1 = SKTexture(imageNamed: "breakingRope-1")
        let breaking2 = SKTexture(imageNamed: "breakingRope-2")
        let breaking3 = SKTexture(imageNamed: "breakingRope-3")
        
        
        //Creiamo le diverse animazioni
        
        //Queste due azioni modificano l'alpha da 0 ad 1 e viceversa
        fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.7)
        
        // Animazioni per il "You Can Whip"
        youCanWhip = SKAction.animate(with: [canWhip1, canWhip2], timePerFrame: 0.35)
        youCanWhip = SKAction.repeatForever(youCanWhip)
        
        
        // animazione per il landing del galleggiante
        landingBaitAnimation = SKAction.animate(with: [gall2, gall3, gall4, gall6, gall5], timePerFrame: 0.2)
        // Animazione di quando il galleggiante sta sull'acqua
        wigglingBaitAnimation = SKAction.animate(with: [gall6, gall4, gall6, gall5], timePerFrame: 0.2)
        // Animazione di quando il galleggiante sta venendo tirato
        baitBeeingTrown = SKAction.animate(with: [gall2, gall3, gall4, gall5], timePerFrame: 0.1)
        
        
        // Animazione di quando lanciamo la canna da pesca
        // !!! Questa è una azione speciale, viene eseguito del codice come fosse una azione spritekit !!!
        let scriptedAction = SKAction.run {
            self.movimentoAmoAlLancio()
            self.resetBools()
            self.showRope = true
        }
        let trowing = SKAction.animate(with: [fishingRod2, fishingRod3, fishingRod4, fishingRod5, fishingRod6, fishingRod7], timePerFrame: 0.1)
        let trowing2 = SKAction.animate(with: [fishingRod1, fishingRod8, fishingRod9, fishingRod8, fishingRod1], timePerFrame: 0.1)
        trowingFishingRod = SKAction.sequence([trowing, scriptedAction, trowing2])
        infiniteIdleAnimation = SKAction.animate(with: [fishingRod1], timePerFrame: 1)
        infiniteIdleAnimation = SKAction.repeatForever(infiniteIdleAnimation)
        
        // Animazione di quando il pesce tira la lenza
        pullingFishingRod = SKAction.animate(with: [fishingRod10, fishingRod11], timePerFrame: 0.3)
        // ... Resa infinita
        pullingFishingRod = SKAction.repeatForever(pullingFishingRod)
        
        // Si crea l'animazione infinita per il galleggiante
        let infiniteWigglingBaitAnimation = SKAction.repeatForever(wigglingBaitAnimation)
        baitGroupAnimation = SKAction.group([landingBaitAnimation, infiniteWigglingBaitAnimation])
        // Creo l'animazione infinita per  quando il pesce ha abboccato
        let baiting = SKAction.animate(with: [gall2, gall3, gall4, gall6, gall5], timePerFrame: 0.1)
        infiniteBaitingAnimation = SKAction.repeatForever(baiting)
        // Creo la animazione di idle
        infiniteBaitIdle = SKAction.animate(with: [gall1], timePerFrame: 1)
        infiniteBaitIdle = SKAction.repeatForever(infiniteBaitIdle)
        
        // Animaizone per la rottura e scappaggio pesce della lenza
        let breaking = SKAction.animate(with: [breaking1, breaking2, breaking3], timePerFrame: 0.3)
        self.breakingRope = SKAction.sequence([breaking, trowing2])
        
        // Creo l'animazione di quando il pesce pescato viene mostrato a schermo
        infiniteFish1Animation = SKAction.animate(with: [fish11, fish12], timePerFrame: 0.14)
        infiniteFish2Animation = SKAction.animate(with: [fish21, fish22], timePerFrame: 0.14)
        infiniteFish1Animation = SKAction.repeatForever(infiniteFish1Animation)
        infiniteFish2Animation = SKAction.repeatForever(infiniteFish2Animation)
       
        
        
        self.trowingPT2 = trowing2
        
        // Inizializziamo il backGround
        self.backGround = BackGround(scene: self)
        // Si inizializzano i sistemi di controllo centrale
        // La tavola dei valori giornaliera
        self.initializeTable()
        // La collezione dei pesci
        self.fishCollection = FishCollection(scene: self, savingCenter: savingCenter)
        // E la classe che gestisce il trofeo vinto
        self.fish = Fish(scene: self, savingCenter: savingCenter, collection: fishCollection)
        // Di base viene aggiornato la collezione la quando si apre il gioco, per settare le texture corrette
        self.fishCollection.updateCollection()
        // La GUI dei pesci rari più comuni
        self.commonFishGUI = CommonFishesGUI(scene: self, savingCenter: self.savingCenter)
        // Il segnale che si illumina quando la lenza ha una bassa durabilità
        self.blinkingSignal = BlinkingRedSignal(scene: self)
        // Le mosche
        self.fly = Fly(scene: self, savingCenter: self.savingCenter)
        // Ed infine un elemento importantissimo, il latency moduler
        // Che ci permette di caprire la latenza del segnale tra watch ed iphone
        self.latencyModuler = LatencyModuler(scene: self, viewModel: self.viewModel)
        
    }
    
    private func logaritmo (base: Double, argomento: Double) -> Double {
        return log(argomento) / log(base)
    }
    
    func setViewModel(viewModel: ViewModel){
        
        self.viewModel = viewModel
        
    }
    
    public func hideGamingScene(){
        
        self.mainMenu.run(SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true))
        self.fishCollection.hideCollectionButton()
        self.mainMenu.run(fadeOut)
        self.fishingRod.run(fadeOut)
        self.semafero.run(fadeOut)
        self.canPressMainMenu = false
        self.setSemaferoRed = true
        viewModel.sendMessage(key: "canTrow", value: 0)
        
    }
    
    public func showGamingScene(){
        
        viewModel.sendMessage(key: "canTrow", value: 1)
        viewModel.sendMessage(key: "canTrowSecondSignal", value: 1)
        self.handleACKs()
        self.fishCollection.showCollectionbutton()
        self.latencyModuler.moveSignalDown()
        self.setSemaferoGreen = true
        self.fishingRod.run(fadeIn)
        self.semafero.run(fadeIn)
        self.mainMenu.run(fadeIn)
        self.canPressMainMenu = true
        self.menuOpen = false
        
    }
    
    private func handleACKs(){
        
        // Questa variabile conta gli ack da dover ricevere
        var bothACKs = 0
        
        // Questo timer molto veloce ed insistente attende che i segnali siano arrivati
        // Al watch e che siano stati inviati degl ack positivi. In entrambi i segnali, se questi
        // Non sono arrivati vengono reinviati
        // Al momento in cui entrambi i segnali sono arrivati, il timer si auto invalida
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true){ timer in
            
            if self.viewModel.canTrowRecieved == 1 {
                print("Segnale cantrow arrivato, smetto di inviarlo indietro")
                self.viewModel.canTrowRecieved = 0
                bothACKs += 1
            } else {
                print("Reinvio il canTrow")
                self.viewModel.sendMessage(key: "canTrow", value: 1)
            }
            
            if self.viewModel.canTrowSecondSignalRecieved == 1 {
                print("Segnale cantrow2 arrivato, smetto di inviarlo indietro")
                self.viewModel.canTrowSecondSignalRecieved = 0
                bothACKs += 1
            } else {
                print("Reinvio il secondSignale")
                self.viewModel.sendMessage(key: "canTrowSecondSignal", value: 1)
            }
            
            if bothACKs >= 2 {
                timer.invalidate()
            }
            
            
        }
        
        
    }
    
    public func getCurrentState() -> Int{
        
        return currentState
        
    }
    
    private func showTutorial() {
        
        if !savingCenter.getSavedBool(key: savingCenter.BLOW_TUTORIAL) {
            
            savingCenter.saveBool(dataToSave: true, key: savingCenter.BLOW_TUTORIAL)
            
            let tutorialNode = SKSpriteNode(imageNamed: "blowTutorial")
            tutorialNode.size = CGSize(width: 470, height: 230)
            tutorialNode.zPosition = 50
            tutorialNode.alpha = 0
            
            self.addChild(tutorialNode)
            tutorialNode.position = CGPoint(x: -480, y: 535)
            tutorialNode.run(self.fadeIn)
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
                    
                if self.viewModel.frDurability > 70 || self.viewModel.frDurability <= 5 {
                    tutorialNode.run(SKAction.sequence([self.fadeOut, SKAction.run {
                        tutorialNode.removeFromParent()
                    }]))
                    
                    timer.invalidate()
                }
            }
        }
        
    }
    
    
}
