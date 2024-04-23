//
//  TableGenerator.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 29/03/24.
//

import Foundation

class TableGenerator{
    
    let savingCenter = SavingsCenter()
    
    // Questa funzione restituisce in output la matrice delle tuple correnti, simboleggianti le percentuali
    // di rarità degli n pesci scelti
    func generateCurrentTable() -> [[Int]]{
        // Genera 10 numeri con upperBound 1771 sulla base del Seed atuale.
        // Questo '1771' corrisponde al numero di tuple calcolate e già memorizzate
        let choosedCombination = chooseCombination(next: false)
        let nextChoosedCombination = chooseCombination(next: true)
        
        var table: [[Int]] = []
        var nextTable: [[Int]] = []
        
        // Vengono estratte dai dati salvati le tuple scelte ed inserite nella matrice di output
        for i in 0...9 {
            
            table.append(savingCenter.getSavedIntArray(key: String("tupla\(choosedCombination[i])")))
            nextTable.append(savingCenter.getSavedIntArray(key: String("tupla\(nextChoosedCombination[i])")))
        }
        
        // Questa funzione schedula la prossima notifica
        NotificationCenter().scheduleNotification(currentTable: nextTable, savingCenter: savingCenter)
        
        print("---Current table---")
        for row in table{
            print(row)
        }
        
        print("\n---Next gameplay table---")
        for row in nextTable{
            print(row)
        }
        return table

    }
    
    func generateTable(){
        
        // Genera tutte le combinazioni possibili filtrando solo quelle corrette
        let combinations = generateCombinations()
        
        // Salviamo in memoria permanente tutte le tuple possibili
        var i = 0
        for solution in combinations {
            print(solution)
            i += 1
            savingCenter.saveIntArray(dataToSave: [solution.0, solution.1, solution.2, solution.3], key: String("tupla\(i)"))
        }
        
    }
    
    // Funzione per generare 10 numeri pseudo-casuali in base alla sequenza alpha
    private func chooseCombination(next: Bool) -> [Int] {
        // Crea un generatore di numeri casuali con il seed calcolato
        var rng = DPRNG(generateNextSeed: next)
        // Genera 10 numeri casuali compresi tra 0 e 1771 sulla base del seed
        var numbers = [Int]()
        
        // Questo ciclo for genera 10 numeri pseudocasuali sulla base del seed giornaliero
        for _ in 0..<10 {
            let randomNumber = Int(rng.next())
            numbers.append(randomNumber)
        }
        return numbers
    }
    
    
    // Questa funzione serve a schedulare la prossima notifica nel caso ce ne sia bisogno

    
    
    private func generateCombinations() -> [(Int, Int, Int, Int)] {
        
      var combinations: [(Int, Int, Int, Int)] = []
        
        for a in 45...90 {
            for b in 20..<a {
                for c in 10..<b {
                    for d in 1..<c {
                        if filterSolution(a: a, b: b, c: c, d: d) {
                            combinations.append((a, b, c, d))
                        }
                    }
                }
            }
        }
        
      return combinations
        
    }

    private func filterSolution(a: Int, b:Int, c:Int, d:Int) -> Bool {
        
        if a + b + c + d == 100 {
            if a > b && b > c && c > d && d < 10{
                return true
            }
        }
        
        return false
        
    }
    
    
}
