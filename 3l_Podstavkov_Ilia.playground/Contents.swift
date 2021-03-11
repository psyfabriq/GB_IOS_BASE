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
    static func parseFields(jsonDict: JSONDict) -> (String, Float, Int, Double, Bool, Bool, Bool, [Int:Thing]) {
        let mark = jsonDict["mark"] as! String
        let trunkWeight = jsonDict["trunk"] as! Float
        let yearIssue = jsonDict["yearIssue"] as! Int
        
        let fuelAmmount = jsonDict["fuel"] as? Double ?? 0
        let isStartEngine = jsonDict["startEnginne"] as? Bool ?? false
        let isOpenWindow = jsonDict["openWindow"] as? Bool ?? false
        let isFullTrunk = jsonDict["fullTrunk"] as? Bool ?? false
        let trunk = jsonDict["things"] as? [Int:Thing] ?? [:]
        
        return (mark, trunkWeight, yearIssue, fuelAmmount, isStartEngine, isOpenWindow, isFullTrunk, trunk)
    }
    
    func info(){
        let a = getWeightAllThingsAndLastKey()
        print(
            "Машина \(mark) , год выпуска \(yearIssue)"
            + "\n топливо : \(fuelAmmount)"
                + "\n багажник/заполнено : \(trunkWeight)/\(isFullTrunk) (\(a.0))"
            + "\n двигатель запушен : \(isStartEngine)"
            + "\n окна открыты : \(isOpenWindow)"
        )
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
                print(AppError.fuelEmpty)
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
            AppError.thingWeryBig
        }else if(self.trunkWeight >= (b.0 + thing.weight)){
            self.trunk[n] = thing
            if (self.trunkWeight - 0.5 <= b.0 + thing.weight) {
                self.isFullTrunk = true
            }
        }else{
            AppError.trunkFull
        }
    }
    
    private mutating func popTrunc(key: Int){
        if self.trunk.index(forKey: key) == nil {
            AppError.thingNotFound
        }else{
            self.trunk.removeValue(forKey: key)
            self.isFullTrunk = false
        }
    }
    
}

struct SportCar: Car {
    var fuelAmmount: Double
    var isStartEngine: Bool
    var isOpenWindow: Bool
    var isFullTrunk: Bool
    var trunk: [Int : Thing]
    let mark: String
    let trunkWeight: Float
    let yearIssue: Int
    init(MARK:SportCarMark, jsonDict: JSONDict) {
        var a: JSONDict  = ["mark":MARK.info.description,"trunk":MARK.info.trunk]
        a.merge(jsonDict) { (current, _) in current }
        (mark,trunkWeight,yearIssue,fuelAmmount,isStartEngine,isOpenWindow,isFullTrunk,trunk) = SportCar.parseFields(jsonDict: a)
    }
}

struct TrunkCar: Car {
    var fuelAmmount: Double
    var isStartEngine: Bool
    var isOpenWindow: Bool
    var isFullTrunk: Bool
    var trunk: [Int : Thing]
    let mark: String
    let trunkWeight: Float
    let yearIssue: Int
    
    init(MARK:TrunkCarMark, jsonDict: JSONDict) {
        var a: JSONDict  = ["mark":MARK.info.description,"trunk":MARK.info.trunk]
        a.merge(jsonDict) { (current, _) in current }
        (mark,trunkWeight,yearIssue,fuelAmmount,isStartEngine,isOpenWindow,isFullTrunk,trunk) = TrunkCar.parseFields(jsonDict: a)
    }
}

var car1 = SportCar(MARK: SportCarMark.jaguar, jsonDict: ["yearIssue": 2004, "fuel": 120.0])
car1.info()
car1.handleAction(action: CarAction.setEngineState(true))
car1.info()
