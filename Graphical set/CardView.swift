//
//  CardView.swift
//  Graphical set
//
//  Created by Wangshu Zhu on 2018/8/12.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import UIKit

class CardView: UIView {
    var card: Card? { didSet{ setNeedsDisplay() } }
    private var shapeColor = UIColor()
    //var UIBezierpath will cause draw twice. deleted
    
    var isFaceUp: Bool = true { didSet{ setNeedsDisplay() } }
    
    var isSelected:Bool = false { didSet{ setNeedsDisplay() } }
    
    var isSet:Bool = false { didSet { setNeedsDisplay() } }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        
        if isFaceUp {
            if isSelected, !isSet {
                UIColor.red.setStroke()
            } else if isSet {
                UIColor.green.setStroke()
            } else {
                UIColor.blue.setStroke()
            }
            roundedRect.lineWidth = 8.0
            roundedRect.fill()
            roundedRect.stroke()
            
            // Drawing code
            drawObject()
        } else {
            UIColor.blue.setStroke()
            roundedRect.lineWidth = 8.0
            roundedRect.fill()
            roundedRect.stroke()
        }
        
    }
    
    private func drawObject() {
        if let card = card {
            let path = UIBezierPath()
            var rectArray = [CGRect]()
            switch card.number {
            case .one:
                rectArray = calcRect(numberOFSymbols: 1)
            case .three:
                rectArray = calcRect(numberOFSymbols: 2)
            case .two:
                rectArray = calcRect(numberOFSymbols: 3)
            }
            
            for index in rectArray.indices {
                let squareLength = calcSquareLength(in: rectArray[index])
                let circleRadius = calcCircleRadius(in: rectArray[index])
                let triangleLength = calcTriangleLength(in: rectArray[index])
                let triangleHeight = calcTriangleHeight(in: rectArray[index])
                
                
                switch card.symbol {
                case .circle:
                    //path.move(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY))
                    path.addArc(withCenter: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY), radius: circleRadius, startAngle: 0.0, endAngle: 2 * CGFloat.pi, clockwise: true)
                case .square:
                    path.move(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: -1/2 * squareLength, dy: -1/2 * squareLength))
                    path.addLine(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: 1/2 * squareLength, dy: -1/2 * squareLength))
                    path.addLine(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: 1/2 * squareLength, dy: 1/2 * squareLength))
                    path.addLine(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: -1/2 * squareLength, dy: 1/2 * squareLength))
                    path.close()
                case .triangle:
                    path.move(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: 0, dy: -2/3 * triangleHeight))
                    path.addLine(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: 1/2 * triangleLength, dy: 1/3 * triangleHeight))
                    path.addLine(to: CGPoint(x: rectArray[index].midX,y: rectArray[index].midY).offsetBy(dx: -1/2 * triangleLength, dy: 1/3 * triangleHeight))
                    path.close()
                } // switch on card.symbol
            } // for index in rectArray
            
            switch card.color {
            case .black:
                shapeColor = UIColor.black
            case .blue:
                shapeColor = UIColor.blue
            case .red:
                shapeColor = UIColor.red
            }
            
            path.addClip()
            
            switch card.shading {
            case .open:
                UIColor.white.setFill()
                shapeColor.setStroke()
                path.fill()
                path.stroke()
            case .solid:
                shapeColor.setFill()
                shapeColor.setStroke()
                path.fill()
                path.stroke()
            case .striped:
                shapeColor.setStroke()
                
                for y in stride(from: 0, to: bounds.height, by: bounds.height / 30) {
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: y, y: 0))
                    path.stroke()
                }
                
                for x in stride(from: 0, to: bounds.width, by: bounds.height / 30) {
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: x, y: bounds.height))
                    path.addLine(to: CGPoint(x: x + bounds.height, y: 0))
                    path.stroke()
                }
                
                
            }
            
            path.stroke()
        }
        
        
    }
    
    
    convenience init(frame: CGRect, card: Card) {
        self.init(frame: frame)
        self.card = card
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private struct constants {
        static let triangleHeight:CGFloat = 180.0
        static let triangleWidth:CGFloat = 180 * 4 / sqrt(3)
    }
    
    
}

extension CardView {
    //functions to calculate symbol properties.squareLength, triangleHeight, circleRadius
    private func calcCircleRadius(in rect:CGRect) -> CGFloat {
        return 1/3 * rect.height
    }
    
    private func calcTriangleHeight(in rect:CGRect) -> CGFloat {
        return calcTriangleLength(in:rect) * (sqrt(3)/2)
    }
    
    private func calcTriangleLength(in rect:CGRect) -> CGFloat {
        return 2/3 * rect.height
    }
    
    private func calcSquareLength(in rect:CGRect) -> CGFloat {
        return 2/3 * rect.height
    }
    
    
    
    private var singleMidPoint:CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var twoFirstMidPoint:CGPoint {
        return singleMidPoint.offsetBy(dx: 0, dy: -1/3 * bounds.height)
    }
    
    private var twoSecondMidPoint:CGPoint {
        return singleMidPoint.offsetBy(dx: 0, dy: 1/3 * bounds.height)
    }
    
    private var threeFirstMidPoint:CGPoint {
        return singleMidPoint.offsetBy(dx: 0, dy: -2/9 * bounds.height)
    }
    
    private var threeSecondMidPoint:CGPoint {
        return singleMidPoint
    }
    
    private var threeThirdMidPoint:CGPoint {
        return singleMidPoint.offsetBy(dx: 0, dy: 2/9 * bounds.height)
    }
    
    //Try to solve number question with CGRect
    private var singleRect:CGRect {
        return CGRect(origin: singleMidPoint, size: CGSize(width: 2/3 * bounds.width, height: 2/3 * bounds.height))
    }
    
    private func calcRect(numberOFSymbols number: Int) -> [CGRect] {
        switch number {
        case 1:
            return [CGRect(origin: singleMidPoint.offsetBy(dx: -1/6 * bounds.width, dy: -1/6 * bounds.height), size: CGSize(width: 1/3 * bounds.width, height: 1/3 * bounds.height))]
        case 2:
            return [
                CGRect(origin: singleMidPoint.offsetBy(dx: -1/3 * bounds.width, dy: -1/3 * bounds.height), size: CGSize(width: 2/3 * bounds.width, height: 1/3 * bounds.height)),
                CGRect(origin: singleMidPoint.offsetBy(dx: -1/3 * bounds.width, dy:  0), size: CGSize(width: 2/3 * bounds.width, height: 1/3 * bounds.height)) ]
        case 3:
            return [CGRect(origin: singleMidPoint.offsetBy(dx: -1/3 * bounds.width, dy: -1/3 * bounds.height), size: CGSize(width: 2/3 * bounds.width, height: 2/9 * bounds.height)),
                    CGRect(origin: singleMidPoint.offsetBy(dx: -1/3 * bounds.width, dy: -1/9 * bounds.height), size: CGSize(width: 2/3 * bounds.width, height: 2/9 * bounds.height)),
                    CGRect(origin: singleMidPoint.offsetBy(dx: -1/3 * bounds.width, dy: 1/9 * bounds.height), size: CGSize(width: 2/3 * bounds.width, height: 2/9 * bounds.height))]
        default:
            return [bounds]
        }
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
