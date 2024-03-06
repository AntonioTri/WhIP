import SwiftUI
import SpriteKit
import WatchKit
 
struct ContentView: View {
    @State private var leverAngle: Double = 0.0
    @State private var force: Double?
    let minAngle: Double = 0.0
    let maxAngle: Double = 100000
    let maxRotationSpeed: Double = 20.0 //Max.R 50
    
    var body: some View {
        VStack {
            ZStack {
                SpriteView(scene: {
                    let scene = SKScene(size: CGSize(width: WKInterfaceDevice.current().screenBounds.width, height: WKInterfaceDevice.current().screenBounds.height))
                    
                    let mulinelloTexture = SKTexture(imageNamed: "Mulinello2")
                    let mulinello = SKSpriteNode(texture: mulinelloTexture)
                    mulinello.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
                    mulinello.setScale(3.5)
                    scene.addChild(mulinello)
                    
                    return scene
                }())
                .frame(width: WKInterfaceDevice.current().screenBounds.width,
                       height: WKInterfaceDevice.current().screenBounds.height)
                
                LevaView(angle: $leverAngle)
            }
            .focusable(true)
            .digitalCrownRotation($leverAngle, from: minAngle, through: maxAngle, by: rotationSpeed())
            .onChange(of: leverAngle) { angle in
                // Imposta la forza solo se non è stata ancora impostata
                if force == nil {
                    force = calculateForce(leverAngle: angle)
                }
            }
        }
    }
    
    func calculateForce(leverAngle: Double) -> Double {
        let maxForce: Double = 100.0
        let force = maxForce * (leverAngle / maxAngle)
        return force
    }
    
    func rotationSpeed() -> Double {
        if let force = force {
            return maxRotationSpeed * (1 - force)
        } else {
            return maxRotationSpeed
        }
    }
}
 
struct LevaView: View {
    @Binding var angle: Double
 
    var body: some View {
        Image("Leva")
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(angle))
            .offset(x: 3, y: -4.8)
    }
}
