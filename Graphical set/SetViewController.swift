//
//  SetViewController.swift
//  Graphical set
//
//  Created by Wangshu Zhu on 2018/8/13.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    @IBOutlet weak var setBoardView: SetBoardView! {
        didSet{
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardTouched(recognizer:)))
            setBoardView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func newGameButtonTouched(_ sender: Any) {
        if sender is UIButton {
            set = SetGame()
            grid.cellCount = 12
            hintedButtons.removeAll()
            matchedButtons.removeAll()
            removeAllCards()
            cardViews.removeAll()
            animateDeal()
        }
    }
    
    @IBAction func dealMoreButtonTouched(_ sender: UIButton) {
        if set.dealThreeMore() {
            var delay = 0.0
            grid.cellCount = cardViews.count + 3
            
            for index in cardViews.indices {
                UIView.transition(with: self.cardViews[index], duration: 0.6, options: .curveEaseInOut,
                                  animations: {
                                    self.cardViews[index].frame = self.grid[index]!
                })
            }
            for index in  set.cardsOnTable.endIndex - 3 ... set.cardsOnTable.endIndex - 1{
                if let cardFrame = grid[index] {
                    let card = CardView(frame: CGRect(origin: self.dealButton.frame.origin , size: cardFrame.size),
                                        card: self.set.cardsOnTable[index])
                    cardViews += [card]
                    delay = 0.1 * Double(cardViews.index(of: card)! - (set.cardsOnTable.count - 3))
                    print(cardViews.index(of: card)!)
                    print(delay)
                    setBoardView.addSubview(card)
                }
                UIView.animate(withDuration: 0.6, delay: delay, options: .curveEaseInOut, animations: {
                    self.cardViews[index].frame = self.grid[index]!
                }, completion: { finished in
                    UIView.transition(with: self.cardViews[index], duration: 0.6, options: .transitionFlipFromLeft, animations: {
                        self.cardViews[index].isFaceUp = !self.cardViews[index].isFaceUp
                    }, completion: { finished in
                        self.cardViews[index].isUserInteractionEnabled = true
                    })
                })
            }
            
            
        } else {
            let alert = UIAlertController(title: "Alert", message: "there is no more card left in the deck", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func hintButtonTouched(_ sender: UIButton) {
        hintedButtons.removeAll()
        clearSelection()
        set.provideHint()
        if  !set.hintCards.isEmpty {
            for index in 0..<3 {
                hintedButtons += [cardViews[set.cardsOnTable.index(of: set.hintCards[index])!]]
                cardViews[cardViews.index(of: hintedButtons[index])!].isSelected = true
            }
        }
        //TODO: Update button color
        
    }
    
    @objc func cardTouched(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .changed: fallthrough
        case .ended :
            let tapPoint = recognizer.location(in: setBoardView)
            for card in cardViews {
                if card.frame.contains(tapPoint){
                    chooseCard(card)
                    scoreLabel.text = "SCORE:\(set.score)"
                }
            }
        default:
            return
        }
    }
    
    private lazy var grid = Grid(layout: .aspectRatio(0.625), frame: setBoardView.bounds)
    private var set = SetGame()
    private var cardViews = [CardView]()
    private var selectedButtons: [CardView] { return cardViews.filter { $0.isSelected } }
    private var hintedButtons = [CardView]()
    private var matchedButtons = [CardView]()
    private var newCards = [CardView]()
    private var numberOfSets: Int = 0
    private let explodeR: CGFloat = 3.0
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var cardBehavior = CardBehavior(in: animator)
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var setButton: UILabel!
    
    
    private func chooseCard(_ sender: CardView) {
        
        if let cardIndex = cardViews.index(of: sender) {
            if !hintedButtons.isEmpty{
                hintedButtons.removeAll()
                clearSelection()
            }
            
            let matchIndicator = set.chooseCard(at: cardIndex)
            //append selected cards
            cardViews[cardIndex].isSelected = !cardViews[cardIndex].isSelected
            
            if selectedButtons.count == 3 {
                if matchIndicator {
                    selectedButtons.forEach {
                        let index  = cardViews.index(of: $0)!
                        
                        matchedButtons.append($0)
                        $0.isSet = true
                        $0.removeFromSuperview()
                        cardViews.remove(at: index)
                        numberOfSets += 1
                        
                        if let cardFrame = self.grid[index] {
                            let cardToInsert = CardView(frame: CGRect(origin: self.dealButton.frame.origin, size: cardFrame.size), card: self.set.cardsOnTable[index])
                            newCards += [cardToInsert]
                            cardViews.insert(cardToInsert, at: index)
                            setBoardView.addSubview(cardToInsert)
                        }
                    }
                        flyIn()
                        flyOut()
                        
                        /*
                         if let cardFrame = self.grid[index] {
                         let cardToInsert = CardView(frame: CGRect(origin: self.dealButton.frame.origin, size: cardFrame.size), card: self.set.cardsOnTable[index])
                         self.cardViews.remove(at: index)
                         self.cardViews.insert(cardToInsert, at: index)
                         let insertDelay = 1.0 * Double(index)
                         UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3.0, delay: insertDelay, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                         cardToInsert.frame = cardFrame
                         }, completion: { (position) in
                         
                         UIView.transition(with: cardToInsert, duration: 3.0, options: .transitionFlipFromLeft, animations: {
                         cardToInsert.isFaceUp = true
                         }, completion: { (finished) in
                         self.setBoardView.addSubview(cardToInsert)
                         cardToInsert.isUserInteractionEnabled = true
                         })
                         })
                         }*/
                    
                    /*
                    matchedButtons.forEach {
                        let index = self.matchedButtons.index(of: $0)!
                        let delay = 5.0 + Double(index)
                        cardBehavior.addItem($0)
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3.0, delay: delay, options: [.transitionFlipFromLeft, .beginFromCurrentState], animations: {
                            self.cardViews[index].isFaceUp = false //happend intantly
                        }, completion: { finished in
                            self.cardBehavior.removeItem(self.cardViews[index])
                            self.animator.removeBehavior(self.cardBehavior)
                            let snapBehavior = UISnapBehavior(item: self.cardViews[index], snapTo: self.setButton.frame.origin)
                            self.animator.addBehavior(snapBehavior)
                            
                        })
                        
                        setBoardView.addSubview(self.cardViews[index])
                    }*/
                }
                
                
                
                //TODO: store selected cards to set and fly in new cards
                
                
            } else if selectedButtons.count == 4 {
                selectedButtons.forEach { $0.isSelected = false }
                cardViews[cardIndex].isSelected = true
            }
            
        } else {
            print ("cardButtonTouched: selected card not in card buttons collection")
            //dose nothing
        }
        
    }
    
    private func flyIn() {
        newCards.forEach { (card) in
            let delay = Double(newCards.index(of: card)!)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: delay, options: .curveEaseInOut, animations: {
                if let cardFrame = self.grid[self.cardViews.index(of: card)!] {
                    card.frame = cardFrame
                }
            }, completion: { (position) in
                UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                    card.isFaceUp = true
                }, completion: { (finished) in
                    card.isUserInteractionEnabled = true
                    
                })
            })
        }
        
        
        newCards.removeAll()
    }
    
    private func flyOut() {
        matchedButtons.forEach { (card) in
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
                let firstTransForm = CGAffineTransform(rotationAngle: (8 * CGFloat.pi).arc4random).translatedBy(x: CGFloat(100.0).arc4random, y: CGFloat(100.0).arc4random)
                card.transform = firstTransForm
                //card.frame = self.cardViews[index].frame.offsetBy(dx: self.explodeR * sin(randomAngle), dy: self.explodeR * cos(randomAngle))
            }, completion: { finished in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
                    //card.transform = CGAffineTransform(rotationAngle: (8 * CGFloat.pi).arc4random).translatedBy(x: CGFloat(100.0).arc4random, y: CGFloat(100.0).arc4random)
                    card.transform = CGAffineTransform.identity
                }, completion: { (position) in
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
                        card.transform = CGAffineTransform(rotationAngle: (8 * CGFloat.pi).arc4random).translatedBy(x: CGFloat(100.0).arc4random, y: CGFloat(100.0).arc4random)
                    }, completion: { (position) in
                        let snapBehavior = UISnapBehavior(item: card, snapTo: self.setButton.frame.origin)
                        self.animator.addBehavior(snapBehavior)
                        self.animator.delegate = self
                        self.previousTransForm = CGAffineTransform.identity
                    })
                })
            })
            self.view.addSubview(card)

        }
        
        setButton.text = "\(numberOfSets) SET"
    }
    
    private var previousTransForm = CGAffineTransform()
    
    private func transForm(_ card:CardView) {
        card.transform = previousTransForm.concatenating(CGAffineTransform(rotationAngle: (8 * CGFloat.pi).arc4random).translatedBy(x: CGFloat(100.0).arc4random, y: CGFloat(100.0).arc4random))
        
    }
    
    internal func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        matchedButtons.forEach { (card) in
            
            UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                card.isFaceUp = !card.isFaceUp
            }, completion: { (finished) in
                card.alpha = 0
                card.isUserInteractionEnabled = false
            })
        }
        
       
        matchedButtons.removeAll()
        setButton.text = "\(numberOfSets) SET"
    }
    
    private func updateViewFromModel() {
        grid.cellCount = set.cardsOnTable.count
        cardViews.removeAll()
        for index in set.cardsOnTable.indices {
            cardViews += [CardView(frame: grid[index]!, card: set.cardsOnTable[index])]
            cardViews[index].isFaceUp = true
            setBoardView.addSubview(cardViews[index])
        }
    }
    
    private func clearSelection() {
        for card in cardViews {
            card.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        grid.cellCount = set.cardsOnTable.count
        animateDeal()
        // Do any additional setup after loading the view.
    }
    
    
    private func animateDeal() {
        var delayTime = 0.0
        for index in set.cardsOnTable.indices {
            delayTime = 0.1 * Double(index)
            if let cardFrame = grid[index] {
                let card = CardView(frame:CGRect(origin: self.dealButton.frame.origin, size: cardFrame.size),
                                    card: set.cardsOnTable[index])
                UIView.animate(withDuration: 0.7, delay: delayTime, options: .curveEaseInOut, animations: {
                    card.frame = cardFrame
                    self.dealButton.isUserInteractionEnabled = false
                },completion: { finished in
                    UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                        card.isFaceUp = !card.isFaceUp
                    }, completion: { finished in
                        card.isUserInteractionEnabled = true
                        self.dealButton.isUserInteractionEnabled = true
                    })
                })
                cardViews.append(card)
                setBoardView.addSubview(cardViews[index])
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grid = Grid(layout: .aspectRatio(0.625), frame: setBoardView.bounds)
        grid.cellCount = set.cardsOnTable.count
        for index in cardViews.indices {
            if let cardFrame = grid[index] {
                print(index)
                cardViews[index].frame = cardFrame
                cardViews[index].setNeedsDisplay()
            }
        }
    }
    
    private func removeAllCards() {
        for card in cardViews {
            card.removeFromSuperview()
        }
        cardViews.removeAll()
    }
    
    
    
     /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
