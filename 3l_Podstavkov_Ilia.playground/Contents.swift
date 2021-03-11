import Foundation

typealias JSONDict = [String:Any]


enum AppError: String {
    case thingWeryBig = "Багаж слишком большой"
    case trunkFull = "Багажник заполнен"
    case thingNotFound = "Багаж не найден"
    case fuelEmpty = "Нет топлива"
}

struct Thing {
    let name: String
    let weight: Float
}

enum CarAction {
    case setEngineState(Bool)
    case setWindowState(Bool)
    case pullThings(Thing)
    case popThing(Int)
}

enum SportCarMark {
    case porsche
    case jaguar
    case mercedes
    case chevrolet
    
    var info: (description: String, trunk: Float) {
          switch self {
          case .porsche:
              return ("Porsche 911", 22)
          case .jaguar:
            return ("Jaguar F-Type", 14.5)
          case .mercedes:
              return ("Mercedes-AMG GT", 16)
          case .chevrolet:
            return ("Chevrolet Corvette C8", 18.787)
          }
      }
}

enum TrunkCarMark {
    case maz
    case hyundai
    case kamaz
    case isuzu
    
    var info: (description: String, trunk: Float) {
          switch self {
          case .maz:
            return ("МАЗ-5440", 1200.546)
          case .hyundai:
              return ("Hyundai Mighty", 800.546)
          case .kamaz:
              return ("КамАЗ-65207", 1800.546)
          case .isuzu:
              return ("Isuzu Elf", 1000.00)
          }
      }
}

protocol Car {
    var type: String { get }
    var mark: String { get }
    var trunkWeight: Float { get }
    var yearIssue: Int { get }
    
    var fuelAmmount: Double {get set}
    
    var isStartEngine: Bool {get set}
    var isOpenWindow: Bool {get set}
    var isFullTrunk: Bool {get set}
    
    var trunk: [Int:Thing] {get set}
}

extension Car {
    static func parseFields(jsonDict: JSONDict) -> (String,String, Float, Int, Double, Bool, Bool, Bool, [Int:Thing]) {
        let type = jsonDict["type"] as! String
        let mark = jsonDict["mark"] as! String
        let trunkWeight = jsonDict["trunk"] as! Float
        let yearIssue = jsonDict["yearIssue"] as! Int
        
        let fuelAmmount = jsonDict["fuel"] as? Double ?? 0
        let isStartEngine = jsonDict["startEnginne"] as? Bool ?? false
        let isOpenWindow = jsonDict["openWindow"] as? Bool ?? false
        let isFullTrunk = jsonDict["fullTrunk"] as? Bool ?? false
        let trunk = jsonDict["things"] as? [Int:Thing] ?? [:]
        
        return (type,mark, trunkWeight, yearIssue, fuelAmmount, isStartEngine, isOpenWindow, isFullTrunk, trunk)
    }
    
    func info(){
        let a = getWeightAllThingsAndLastKey()
        print(
            "Машина \(mark) (\(type)), год выпуска \(yearIssue)"
            + "\n топливо : \(fuelAmmount)"
            + "\n багажник/заполнено : \(trunkWeight)/\(isFullTrunk) (\(a.0))"
            + "\n двигатель запушен : \(isStartEngine)"
            + "\n окна открыты : \(isOpenWindow)"
        )
    }
    
    func truncInfo(){
        for (key, value) in  self.trunk {
            print("\(key) : '\(value.name)' : \(value.weight) ")
        }
    }
    
        mutating func handleAction(action: CarAction) {
            switch action {
            case .setEngineState(let state):
                startEngine(state: state)
            case .setWindowState(let state):
                openWindow(state: state)
            case .pullThings(let thing):
                putTrunc(thing: thing)
            case .popThing(let key):
                popTrunc(key: key)
            }
        }
    
    private mutating func startEngine(state: Bool){
        if state && !isStartEngine {
            guard self.fuelAmmount > 0 else {
                print(AppError.fuelEmpty.rawValue)
                return
            }
            self.isStartEngine = true
            print("Запуск двигателя")
        } else if isStartEngine{
            self.isStartEngine = false
            print("Выключили двигатель")
        }
    }
    
    private mutating func openWindow(state: Bool){
        if state && !isOpenWindow {
            self.isOpenWindow = true
            print("Окна открыть")
        }else if isOpenWindow {
            self.isOpenWindow = false
            print("Окна закрыть")
        }
    }
   
    private func getWeightAllThingsAndLastKey() -> (Float, Int){
        var res: Float = 0
        var lasKey: Int = 0
        for (key, value) in  self.trunk {
            res += value.weight
            lasKey = max(lasKey,key)
        }
        return (res, lasKey)
    }
    
    private mutating func putTrunc(thing: Thing){
        let b = getWeightAllThingsAndLastKey()
        let n = b.1+1
        if(self.trunkWeight < thing.weight){
            print(AppError.thingWeryBig.rawValue)
        }else if(self.trunkWeight >= (b.0 + thing.weight)){
            self.trunk[n] = thing
            if (self.trunkWeight - 0.5 <= b.0 + thing.weight) {
                self.isFullTrunk = true
            }
        }else{
            print(AppError.trunkFull.rawValue)
        }
    }
    
    private mutating func popTrunc(key: Int){
        if self.trunk.index(forKey: key) == nil {
            print(AppError.thingNotFound.rawValue)
        }else{
            self.trunk.removeValue(forKey: key)
            self.isFullTrunk = false
        }
    }
    
}

struct SportCar: Car {
    var type: String
    
    var fuelAmmount: Double
    var isStartEngine: Bool
    var isOpenWindow: Bool
    var isFullTrunk: Bool
    var trunk: [Int : Thing]
    let mark: String
    let trunkWeight: Float
    let yearIssue: Int
    init(MARK:SportCarMark, jsonDict: JSONDict) {
        var a: JSONDict  = ["type":"Спортивная машина", "mark":MARK.info.description,"trunk":MARK.info.trunk]
        a.merge(jsonDict) { (current, _) in current }
        (type , mark,trunkWeight,yearIssue,fuelAmmount,isStartEngine,isOpenWindow,isFullTrunk,trunk) = SportCar.parseFields(jsonDict: a)
    }
}

struct TrunkCar: Car {
    var type: String
    
    var fuelAmmount: Double
    var isStartEngine: Bool
    var isOpenWindow: Bool
    var isFullTrunk: Bool
    var trunk: [Int : Thing]
    let mark: String
    let trunkWeight: Float
    let yearIssue: Int
    
    init(MARK:TrunkCarMark, jsonDict: JSONDict) {
        var a: JSONDict  = ["type":"Грузовик", "mark":MARK.info.description,"trunk":MARK.info.trunk]
        a.merge(jsonDict) { (current, _) in current }
        (type, mark,trunkWeight,yearIssue,fuelAmmount,isStartEngine,isOpenWindow,isFullTrunk,trunk) = TrunkCar.parseFields(jsonDict: a)
    }
}

var car1 = SportCar(MARK: SportCarMark.jaguar, jsonDict: ["yearIssue": 2004, "fuel": 120.0])
car1.info()
car1.handleAction(action: CarAction.setEngineState(true))
car1.handleAction(action: CarAction.pullThings(Thing.init(name: "60x30x10", weight: 10)))
car1.handleAction(action: CarAction.pullThings(Thing.init(name: "test", weight: 4.0)))

car1.info()
car1.handleAction(action: CarAction.setWindowState(true))
car1.handleAction(action: CarAction.popThing(2))

car1.info()

let things: [Int:Thing] = [
    1 : Thing.init(name: "Pal_1", weight: 22.2),
    2 : Thing.init(name: "Pal_2", weight: 34.4),
    3 : Thing.init(name: "Pal_3", weight: 12.78),
    4 : Thing.init(name: "Pal_4", weight: 80.9),
    5 : Thing.init(name: "Pal_5", weight: 100.0)
]
var car2 = TrunkCar(MARK: TrunkCarMark.kamaz, jsonDict: ["yearIssue": 2020, "fuel": 800.0, "things": things])
car2.info()
car2.truncInfo()

