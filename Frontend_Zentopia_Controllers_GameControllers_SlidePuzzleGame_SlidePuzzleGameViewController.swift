//
//  SlidePuzzleViewController.swift
//  Zentopia
//
//  Created by Aubrey Uriel Sijo-Gonzalez on 9/2/20.
//  Copyright © 2020 Aubrey Uriel Sijo-Gonzalez. All rights reserved.
//

import UIKit
import Foundation

/**
    Slide Puzzle Game view controller
    Displays board of image tiles
 **/
class SlidePuzzleGameViewController: ZentopiaViewController {
    var presenter: SlidePuzzleGameViewPresenter?
    
    // Determine level of difficulty for sliding image puzzle
    var gameLevel = 0
    
    // Determine which picture to load
    var picNum = 1
    
    // Determine number of tiles by row & by column
    var tileBy = 3
    
    // Save instances of image views and center coords for each image
    var puzzleImgViews = [UIImageView]()
    var imgCenters = [CGPoint]()
    
    var viewScreen = UIScreen.main.bounds
    var viewScreenWidth:CGFloat = 0
    var viewScreenHeight:CGFloat = 0
    
    // Calculate center coords for tiles adjacent to current image tile
    var blankTile: CGPoint = CGPoint(x: 0, y: 0)
    var curTile: CGPoint = CGPoint(x: 0, y: 0)
    var upTile: CGPoint = CGPoint(x: 0, y: 0)
    var downTile: CGPoint = CGPoint(x: 0, y: 0)
    var leftTile: CGPoint = CGPoint(x: 0, y: 0)
    var rightTile: CGPoint = CGPoint(x: 0, y: 0)
    
    // Keep track of user's current number of moves
    var moves = 0
    
    // Timer object to track duration of playtime
    var timer = Timer()
    var timeElapsed = 0
    
    // Limiter for tile's center y-coord
    // Adjust according to screen size
    var yCentLimiter = 2.5
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    
    /**
        Load view for sliding image puzzle game
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //debug
        print("Game level: \(gameLevel)")
        
        picNum = Int.random(in: 1...3)
        
        if(gameLevel == 1)
        {
            tileBy = 3
        }
        else if (gameLevel == 2 || gameLevel == 3)
        {
            tileBy = 4
        }
        
        initPuzzleTiles()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        presenter?.onViewLoaded()
        
        /**
            Invoked when user presses "Back" button
            Returns user to Level Select view
        */
        let backButton = ButtonClass(color: UIColor(.PURPLE), text: "Back", segue: "SlideEndPuzzleViewSegue", width: xValue(64.0), height: yValue(48.0))
        
        /**
            Pauses gameplay and timer. User interaction with the board is also disabled.
            Gameplay and timer resumes after user presses "Resume" on the alert box.
        */
        let pauseButton = ButtonClass(color: UIColor(.PURPLE), text: "Pause", segue: "", width: xValue(96.0), height: yValue(48.0), action: {
            self.timer.invalidate()
            
            let pauseAlert = UIAlertController(title: "Game Paused", message: nil, preferredStyle: .alert)
            
            pauseAlert.addAction(UIAlertAction(title: "Resume", style: .default, handler: { action in
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            }))
            
            self.present(pauseAlert, animated: true, completion: nil)
        })
        
        /**
            Invoked when user presses the "Restart" button
            Restarts the timer, moves counter, and reshuffles the board tiles
        */
        let restartButton = ButtonClass(color: UIColor(.PURPLE), text: "Restart", segue: "", width: xValue(96.0), height: yValue(48.0), action: {
            self.timeElapsed = 0
            self.moves = 0
            self.timeLabel.text = "Time: 0 s"
            self.movesLabel.text = "Moves: 0"
            
            while (self.puzzleImgViews.count > 0)
            {
                self.puzzleImgViews[0].removeFromSuperview()
                self.puzzleImgViews.remove(at: 0)
            }
            
            while(self.imgCenters.count > 0)
            {
                self.imgCenters.remove(at: 0)
            }
            
            self.initPuzzleTiles()
        })
        
        /**
            previewImageButtonPressed() invoked when user presses the correcponding button on the Game view
            Display alert box with the correct image
        */
        let previewButton = ButtonClass(color: UIColor(.PURPLE), text: "Preview Full Image", segue: "", width: width - xValue(64.0), height: yValue(48.0), action: {
            let preview = UIAlertController(title: "Preview Image", message: nil, preferredStyle: .alert)
             
            let imgView = UIImageView(frame: CGRect(x: 75 , y: 50, width: 250, height: 250))
            let fullImage = UIImage(named: String(format: "\(self.gameLevel)-\(self.picNum)-full.jpg"))
            
            let previewHeight = NSLayoutConstraint(item: preview.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
            let previewWidth = NSLayoutConstraint(item: preview.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
            
            preview.view.addConstraint(previewHeight)
            preview.view.addConstraint(previewWidth)
            
            imgView.image = fullImage
            preview.view.addSubview(imgView)
            preview.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            
            self.present(preview, animated: true, completion: nil)
        })
        
        self.view.addSubview(backButton)
        self.view.addSubview(pauseButton)
        self.view.addSubview(restartButton)
        self.view.addSubview(previewButton)
        
        backButton.moveRect(newX: xValue(64.0), newY: yValue(84.0))
        pauseButton.moveRect(newX: width - xValue(168.0), newY: yValue(84.0))
        restartButton.moveRect(newX: width - xValue(64.0), newY: yValue(84.0))
        previewButton.moveRect(newX: xCenter, newY: height - yValue(96.0))
    }
    
    /**
        Initialize image tiles for sliding puzzle game
        Store winning sequence of tiles using accessibilityIdentifier
            *refer to gameWon() function for more details
     **/
    func initPuzzleTiles() {
        viewScreenWidth = viewScreen.size.width
        viewScreenHeight = viewScreen.size.height
        
        //debug
        print("--------New puzzle board--------")
        print("view width: \(viewScreenWidth)")
        print("view height: \(viewScreenHeight)")
        
        let timeLabelY = timeLabel.frame.origin.y
        print("timeLabelY: \(timeLabelY)") // debug
        
        var xCent = viewScreenWidth / CGFloat(tileBy * 2)
        var yCent = timeLabelY + viewScreenHeight / CGFloat(tileBy * 2)
        
        // imgSizeLimiter Limits size of tiles according to board difficulty
        var imgSizeLimiter = 0
        
        if (tileBy == 3) {
            imgSizeLimiter = 10
            
            if (viewScreenHeight > 890) {
                yCentLimiter = 3.5
                
            } else if (viewScreenHeight > 800) {
                yCentLimiter = 3.7
                yCent += 20
            }
            else {
                yCentLimiter = 2.5
            }
        }
       
        if (tileBy == 4) {
            imgSizeLimiter = 5
            
            if (viewScreenHeight > 800) {
                yCentLimiter = 4.3
            } else if (viewScreenWidth > 400 && viewScreenHeight > 700) {
                yCentLimiter = 2.8
            } else {
                yCentLimiter = 3
            }
        }
        
        // Populate table of image tiles (in correct order, first)
        // row by row, col by col
        for y in 1...tileBy {
            for x in 1...tileBy {
                let imgTile = UIImage( named: String(format: "\(gameLevel)-\(picNum)-row-%d-col-%d.jpg", y, x) )
                let imgTileSize = ( viewScreenWidth / ( CGFloat(tileBy)) - CGFloat(imgSizeLimiter) )
                
                let imgView = UIImageView( frame: CGRect( x: xCent, y: yCent, width: imgTileSize, height: imgTileSize) )
                imgView.center = CGPoint( x: xCent, y: yCent )
                imgView.image = imgTile
                
                // Note the correct center coords for image tile
                imgView.accessibilityIdentifier = "(\(xCent), \(yCent))"
                      
                view.addSubview(imgView)
                puzzleImgViews.append(imgView)
                imgCenters.append(CGPoint(x: xCent, y: yCent))
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
                imgView.isUserInteractionEnabled = true
                imgView.addGestureRecognizer(tapGestureRecognizer)
                
                xCent += (viewScreenWidth / CGFloat(tileBy))
            }
                xCent = viewScreenWidth / CGFloat(tileBy * 2)
                yCent += viewScreenHeight / (CGFloat(tileBy) + CGFloat(yCentLimiter))
        }
        
        // Remove last img tile before start of game
        puzzleImgViews[puzzleImgViews.count - 1].removeFromSuperview()
        puzzleImgViews.remove(at: puzzleImgViews.count - 1)
        
        //debug
        print("Total number of tiles: \(puzzleImgViews.count)")
        print("*****")
        for i in 0..<imgCenters.count {
            print("\tcenter \(i): \(imgCenters[i])")
        }
        print("*****")
        
        shuffleTiles()
    }
    
    /**
        Shuffle all image tiles on board
     */
    func shuffleTiles() {
        var randNum: Int
        var randCenter: CGPoint
        
        // Array of img centers that haven't been shuffled yet
        // Avoid duplicate random numbers
        var availCenters = imgCenters
        
        for view in puzzleImgViews {
            randNum = Int.random(in: 0..<availCenters.count)
            randCenter = availCenters[randNum]
            
            view.center = randCenter
            availCenters.remove(at: randNum)
        }
        
        blankTile = availCenters[0]
        
        //debug
        print("Blank tile center: \(blankTile)")
    }
    
    /**
        Elapses time by 1 second and handles display of time elapsed on Game view
     **/
    @objc func timerAction(){
        timeElapsed += 1
        timeLabel.text = "Time: \(timeElapsed) s"
    }
    
    /**
        Allows user interaction with image tiles on sliding puzzle board
        Move tiles according to their position on the board
     **/
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedTile = tapGestureRecognizer.view as! UIImageView
        
        let viewScreen = UIScreen.main.bounds
        let viewScreenWidth = viewScreen.size.width
        let viewScreenHeight = viewScreen.size.height
        
        let moveX = viewScreenWidth / CGFloat(tileBy)
        let moveY = viewScreenHeight / ( CGFloat(tileBy) + CGFloat(yCentLimiter) )
        
        curTile     = tappedTile.center
        upTile      = CGPoint(x: curTile.x , y: curTile.y + moveY)
        downTile    = CGPoint(x: curTile.x, y: curTile.y - moveY)
        leftTile    = CGPoint(x: curTile.x - moveX, y: curTile.y)
        rightTile   = CGPoint(x: curTile.x + moveX, y: curTile.y)
        
        if(    (comparePoints(pt1: upTile, pt2: blankTile) == 0)
            || (comparePoints(pt1: downTile, pt2: blankTile) == 0)
            || (comparePoints(pt1: leftTile, pt2: blankTile) == 0)
            || (comparePoints(pt1: rightTile, pt2: blankTile) == 0) )
        {
            tappedTile.center = blankTile
            blankTile = curTile
            
            moves += 1
            movesLabel.text = "Moves: \(moves)"
            if( gameWon() == 0 )
            {
                print("GAME WON") //debug
                timer.invalidate()
                performSegue(withIdentifier: "GameWonViewSegue", sender: self)
            }
        }
    }
    
    /**
        Helper function to compare equality of points
        returns 0 if points are equal, 1 otherwise
     */
    func comparePoints(pt1:CGPoint, pt2:CGPoint) -> Int {
        if(pt1.x == pt2.x && pt1.y == pt2.y)
        {
            return 0
        }
        return 1
    }
    
    /**
        Helper function to parse CGPoint in string format
        returns CGPoint object containing x-coord & y-coord from string
     **/
    func pointStringParser(pt:String) -> CGPoint {
        let xCoordEnd = pt.firstIndex(of: ",") ?? pt.endIndex
        let xCoordRange = pt.index(after: pt.startIndex)..<xCoordEnd
        let xCoord = Float(pt[xCoordRange])
        
        let yCoordEnd = pt.firstIndex(of: ")") ?? pt.endIndex
        let yCoordStart = pt.firstIndex(of: " ") ?? pt.endIndex
        let yCoordRange = pt.index(after: yCoordStart)..<yCoordEnd
        let yCoord = Float(pt[yCoordRange])
        
        return CGPoint( x: CGFloat(xCoord!) , y: CGFloat(yCoord!) )
    }
    
    /**
        Compares two points, which allows for a small margin of difference in distance
     **/
    func compPointsMargin(pt1:CGPoint, pt2:CGPoint) -> Int {
        if(abs(pt1.x - pt2.x) <= 1 && abs(pt1.y - pt2.y) <= 1)
        {
            return 0
        }
        return 1
    }
    
    /**
        gameWon() invoked everytime a valid tile is tapped
        Verifies that all the current center coords for each image tile match the correct center coords
     ***/
    func gameWon() -> Int {
        //debug
        print("Call to gameWon")
        
        for i in 0..<puzzleImgViews.count
        {
            let correctCenter = pointStringParser(pt: puzzleImgViews[i].accessibilityIdentifier!)
            let currentCenter = puzzleImgViews[i].center
            //debug
            print("\tcorrect: \(correctCenter) | current: \(currentCenter)")
            
            if( compPointsMargin(pt1: correctCenter, pt2: currentCenter) != 0 )
            {
                return 1
            }
        }
        return 0
    }
    
    /**
        Pass necessary data to SlidePuzzleGameWonViewController while performing segue to the Game Won view
     **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "GameWonViewSegue"
        else
        {
            return
        }
        
        let props = SlidePuzzleGameWonViewProps(time: timeElapsed, moves: moves, difficulty: gameLevel)
                
        let vc = segue.destination as! SlidePuzzleGameWonViewController
        vc.difficulty = gameLevel
        vc.totalTime = timeElapsed
        vc.totalMoves = moves
        vc.render(props)
    }
}

/***
    Extension to help render slide puzzle game view
 ***/
extension SlidePuzzleGameViewController: SlidePuzzleGameViewComponent {
    
    /**
        Renders the view with the given props values for time and moves labels
     ***/
    func render(_ props: SlidePuzzleGameViewProps) {
        timeLabel.text = "Time: \(props.timeElapsed)s"
        movesLabel.text = "Moves: \(props.moves)"
    }
}
