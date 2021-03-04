import UIKit

//a,b- катеты, с-гипотенуза
let a:Float = 6
let b:Float = 8
// Вычислить Гипотенузу
let c:Float = sqrt(a * a + b * b);

let p:Float = a + b + c

print("Гипотенуза треугольника равна \(c)")
print("Периметр треугольника равен \(p)")
