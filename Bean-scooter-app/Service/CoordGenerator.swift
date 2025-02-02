//
//  CoordGenerator.swift
//  Bean-scooter-app
//
//  Created by Dongik Song on 4/26/24.
//

import Foundation
import CoreData
import UIKit

class CoordGenerator {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func makingDummyArray() { // -> Coredata로 바로 저장.
        
        for _ in 0 ... 9 {
            let newItem = PinData(context: context)
            newItem.id = serialGenerator()
            newItem.x = lonlatGenerator().0
            newItem.y = lonlatGenerator().1
            do {
                try context.save()
            } catch {
            }
        }
    
    }
    
    // 10자리의 랜덤한 SerialNumber를 만들어줌
    func serialGenerator() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let madeString = String((0 ..< 10).map{ _ in letters.randomElement()! })
        return madeString
    }
    
    func lonlatGenerator() -> (Double, Double) {
        
        // 시뮬레이터 기반 Apple 지역 위도,경도
        let defaultLon = -122.030189
        let defaultLat = 37.331676
        // 위도,경도를 250m 환산했을때의 값
        let lonKm = 0.002825
        let latKm = 0.002275
        
        // 애플의 위도,경도를 기준으로 +,- 1km 범위의 랜덤 값을 추출
        let x = Double.random(in: (defaultLon - lonKm ... defaultLon + lonKm))
        let y = Double.random(in: (defaultLat - latKm ... defaultLat + latKm))
        
        return (x, y)
    }
    
    
    
}
