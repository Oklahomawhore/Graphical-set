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
            selectedButtons.removeAll()
            hintedButtons.removeAll()
            matchedButtons.removeAll()
            removeAllCards()
            cardViews.removeAll()
            createCards()
        }
    }
    
    @IBAction func dealMoreButtonTouched(_ sender: UIButton) {
        if set.dealThreeMore(){
            removeAllCards()
            createCards()
        } else {
            let alert = UIAlertController(title: "Alert", message: "there is no more card left in the deck", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func hintButtonTouched(_ sender: UIButton) {
        hintedButtons.removeAll()
        selectedButtons.removeAll()
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
    private var selectedButtons = [CardView]()
    private var hintedButtons = [CardView]()
    private var matchedButtons = [CardView]()
    
    private func chooseCard(_ sender: CardView) {
        if let cardIndex = cardViews.index(of: sender) {
            if !hintedButtons.isEmpty{
                hintedButtons.removeAll()
                clearSelection()
            }
            
            let matchIndicator = set.chooseCard(at: cardIndex)
            //append selected cards
            if !selectedButtons.contains(sender) { // if selected button is not already selected
                if selectedButtons.count < 2 { //select new button
                    for card in matchedButtons {
                        card.isHidden = true
                    }
                    cardViews[cardIndex].isSelected = true
                    selectedButtons.append(sender)
                } else if selectedButtons.count == 2 { //select third button
                    if matchIndicator { //selected third button and selected buttons are a match
                        selectedButtons.append(sender)
                        for card in selectedButtons {
                            card.isSet = true
                        }
                    } else { // selected third button but not a match
                        cardViews[cardIndex].isSelected = true
                        selectedButtons.append(sender)
                    }
                } else { // selected more than three buttons clear selected buttons and add first one.
                    for button in selectedButtons{
                        cardViews[cardViews.index(of: button)!].isSelected = false
                    }
                    selectedButtons.removeAll()
                    selectedButtons.append(sender)
                    sender.isSelected = true
                }
            } else { //deselection utility
                selectedButtons.remove(at: selectedButtons.index(of: sender)!)
                sender.isSelected = false
            }
            
        } else {
            print ("cardButtonTouched: selected card not in card buttons collection")
            //dose nothing
        }
        
    }
    
    private func clearSelection() {
        for card in cardViews {
            card.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        createCards()
        
        // Do any additional setup after loading the view.
    }
    
    /*
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        grid.frame = setBoardView.bounds
        for index in cardViews.indices {
            cardViews[index].frame = grid[index]!
            cardViews[index].setNeedsLayout()
        }
    }
    */
    
    
    private func createCards() {
        grid.cellCount = set.cardsOnTable.count
        for index in set.cardsOnTable.indices {
            if let cardFrame = grid[index] {
                cardViews.append(CardView(frame: cardFrame, card: set.cardsOnTable[index]))
                setBoardView.addSubview(cardViews[index])
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
