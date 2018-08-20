//
//  SetViewController.swift
//  Graphical set
//
//  Created by Wangshu Zhu on 2018/8/13.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    @IBOutlet weak var setBoardView: SetBoardView!
    
    private lazy var grid = Grid(layout: .aspectRatio(0.625), frame: setBoardView.bounds)
    private var set = SetGame()
    private var selectedButtons = [CardView]()
    private var hintedButons = [CardView]()
    private var matchedButtons = [CardView]()

    override func viewDidLoad() {
        createCards()
        for index in set.cardsOnTable.indices {
            if let cardFrame = grid[index] {
                setBoardView.addSubview(CardView(frame: cardFrame, card: set.cardsOnTable[index]))
            }
        }
        // Do any additional setup after loading the view.
    }
    
    private func createCards() {
        grid.cellCount = set.cardsOnTable.count
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
