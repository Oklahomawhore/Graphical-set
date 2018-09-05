//
//  SetViewController.swift
//  Graphical set
//
//  Created by Wangshu Zhu on 2018/8/13.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
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
            hintedButtons.removeAll()
            matchedButtons.removeAll()
            removeAllCards()
            cardViews.removeAll()
            animateDeal()
        }
    }
    
    @IBAction func dealMoreButtonTouched(_ sender: UIButton) {
        if set.dealThreeMore(){
            removeAllCards()
            updateViewFromModel()
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
    
    private lazy var animator = UIDynamicAnimator(referenceView: self.setBoardView)
    
    
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
                    cardViews = cardViews.map {
                        if $0.isSelected {
                            if let index = cardViews.index(of: $0) {
                                $0.card = set.cardsOnTable[index]
                            }
                        }
                        return $0
                    }
                    
                    selectedButtons.forEach {
                        matchedButtons.append($0)
                        $0.isSet = true
                        $0.isSelected = false
                    }
                    
                    //TODO: store selected cards to set and fly in new cards
                    
                }
            } else if selectedButtons.count == 4 {
                    selectedButtons.forEach { $0.isSelected = false }
                    cardViews[cardIndex].isSelected = true
            }

        } else {
            print ("cardButtonTouched: selected card not in card buttons collection")
            //dose nothing
        }
        
    }
    
    private func updateViewFromModel() {
        grid.cellCount = set.cardsOnTable.count
        cardViews.removeAll()
        for index in set.cardsOnTable.indices {
            cardViews += [CardView(frame: grid[index]!, card: set.cardsOnTable[index])]
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
                let card = CardView(frame:CGRect(x: dealButton.frame.origin.x, y: dealButton.frame.origin.y, width: cardFrame.width, height: cardFrame.height),
                                    card: set.cardsOnTable[index])
                UIView.animate(withDuration: 0.7, delay: delayTime, options: .curveEaseInOut, animations: {
                    card.frame = cardFrame
                    },completion: { finished in
                        UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                            card.isFaceUp = !card.isFaceUp
                        }, completion: { finished in
                            UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                                card.isFaceUp = !card.isFaceUp
                            }, completion: { finished in
                                card.isUserInteractionEnabled = true
                            })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
