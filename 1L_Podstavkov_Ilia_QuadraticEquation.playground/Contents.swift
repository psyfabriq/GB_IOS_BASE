import UIKit

// https://www.youtube.com/watch?v=3Uz7JZVtgJE
// 1. Решить квадратное уравнение

let a:Float = 3
let b:Float = 23
let c:Float = 2

var x1:Float
var x2:Float
var d:Float // Корень квадратный Дискриминант

let dis:Float = b * b - (4 * a * c) // вычисляем Дискриминант


if(dis > 0){
    d = sqrt(dis)
    x1 = (-b + d) / (2 * a)
    x2 = (-b - d) / (2 * a)
    print(x1, x2)
}else if(dis == 0){
    x1 = -b / (2 * a)
    x2 = x1
    print(x1, x2)
}else{
    print("Корней нет")
}
