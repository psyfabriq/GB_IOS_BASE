import UIKit
var monthesDays:[Int:Int] = [1:31,2:28,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31] //Дней в месяце
var monthesNames:[Int:String] = [1:"Январь",2:"Февраль",3:"Март",4:"Апрель",5:"Май",6:"Июнь",7:"Июль",8:"Август",9:"Сентябрь",10:"Октябрь",11:"Ноябрь",12:"Декабрь"] //Дней в месяце

let deposit:Float = 250000
let percent:Float = 9.5 // Процент годовой
let years:Float = 5 // 5 лет
let month:Int = Int(years) * 12

let j:Float = percent/(100 * 365) // коэфициент процента

var mn:Int = 3 //текушей месяц
var profit:Float = 0
var i = 1
 
repeat {
 
    let _days:Int = monthesDays[mn]!
    let _name:String = monthesNames[mn]!
    let _mp:Float = (deposit + profit) * Float(_days) * j
    
    profit += _mp
    
    print("Проценты за " + _name + " (" + String(i) + ") --- > " + String(_mp))
    
    if mn < 12{
        mn+=1
    }else{
        mn = 1
    }
    
    i+=1
} while i <= month

print("Прибыль за " + String(Float(month/12)) + " лет : " + String(profit))
