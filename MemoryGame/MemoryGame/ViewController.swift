//
//  ViewController.swift
//  MemoryGame
//
//  Created by Brian Xu on 3/1/2018.
//  Copyright © 2018 Fake Name. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftSpinner

class ViewController: UIViewController {
    
    var images: [UIImage] = [
        UIImage(named: "apple.png")!,
        UIImage(named: "bread.png")!,
        UIImage(named: "burger.png")!,
        UIImage(named: "cupcake.png")!,
        UIImage(named: "donut.png")!,
        UIImage(named: "hotdog.png")!,
        UIImage(named: "onigiri.png")!,
        UIImage(named: "pizza.png")!,
        UIImage(named: "pudding.png")!,
        UIImage(named: "sushi.png")!,
    ]
    // array containing all of the images I stole from internet creators
 
    var imageCenters = Array<CGPoint>()
    // creates an array for positions of UIImageViews created in makeGrid
    // later used in randomisation function
    var imageViews = Array<UIImageView>()
    // creates an array for UIImageViews created in makeGrid
    // later used in basically everything
    
    var timer = Timer()
    var timeLeft = 0
    // attempt to make 'fair' starting time
    
    var totalScore = 0
    var currentScore = 0
    var roundNumber = 0
    
    var nImageTapped = 0
    var nFirstImageTapped = 0
    var nSecondImageTapped = 0
    var direction = 0
    // direction for spinny spin
    
    var compareImages = 0
    // these are here to compare two tapped images
    var tapLock = 0
    // this is here so that tap function does not break if someone
    // spam taps during the time penalisation
    // ^all of the above are used in the tap action
    
    // let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappedFunction))
    
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var scoresStackView: UIStackView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var gridView: UIView!
    // ^I only made these so that the game would stop crashing
    // whenever tap function was used
    @IBOutlet weak var timeLabel: UILabel!
    // timeLabel which is currently unused
    
    
    
    let alert = UIAlertController(title: "GAME OVER", message: "", preferredStyle: UIAlertControllerStyle.alert)
    // game over alert
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        SwiftSpinner.show("3")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftSpinner.show("2")
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.reset()
            
            SwiftSpinner.show("1")
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            SwiftSpinner.hide()
        }
        
        
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.reset()
        }))
        alert.addAction(UIAlertAction(title: "Menu", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "back", sender: self)
        }))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  
    }
    
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        reset()
        // this is a reset button.
    }
    
    func updateScore() {
        currentScore = currentScore + 1
        scoreLabel.text = ("SCORE: " + String(currentScore))
    }
    
    func updateTotalScore() {
        totalScore = totalScore + 1
        totalScoreLabel.text = ("TOTAL: " + String(totalScore))
        
    }
    
    func updateRounds() {
        roundNumber = roundNumber + 1
        roundNumberLabel.text = ("ROUND: " + String(roundNumber))
 
    }
    
    func resetScore() {
        currentScore = 0
        scoreLabel.text = ("SCORE: " + String(currentScore))
    }

    func updateTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.deadline), userInfo: nil, repeats: true)
    
    }
    
    @objc func deadline() {
        timeLeft = timeLeft - 1
         timeLabel.text = ("TIME: " + String(timeLeft))
    
        if (currentScore == 10) {
                
            totalScore = totalScore + timeLeft
            totalScoreLabel.text = ("TOTAL: " + String(totalScore))
            // auto-reset when all matches have been made as well as
            // score addition equal to remaining time
            
            reset()
        }
        else if (timeLeft == 0) {
            timer.invalidate()
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func reset() {
        for imageView in gridView.subviews {
            imageView.removeFromSuperview()
        }
        // removes all previously generated UIImageViews
        imageViews.removeAll()
        // clears array
        // ^ only this array needs to be cleared as the
        // array created for positions has already been cleared
        
        makeGrid()
        
        for imageView in imageViews {
            imageView.image = UIImage(named: "none.png")
            // hides the images, which have already been assigned
            // to certain UIImageViews
        }
        
        resetScore()
        updateRounds()
        timeLeft = 41
        timer.invalidate()
        updateTimer()
        
        tapLock = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tapLock = 0
            
        }
        
        compareImages = 0
        
    }
    
    func randomisePosition() {
        // randomises position of images using positions
        // in array imageCenters that were created in makeGrid
        
        var maxIndex = UInt32(imageCenters.count)
        var randomIndex = Int(arc4random_uniform(maxIndex))
        var randomCenter = imageCenters[randomIndex]
        
        for imageView in imageViews {
            
            maxIndex = UInt32(imageCenters.count)
            randomIndex = Int(arc4random_uniform(maxIndex))
            randomCenter = imageCenters[randomIndex]
            imageView.center = randomCenter
            imageCenters.remove(at: randomIndex)
            // last line so that no two UIImageViews may occupy the same position
            // ^accomplished by removing a position from the array the moment
            // it becomes occupied
        }
    }
    
    func makeGrid() {
        
        // neglected to change name of function for now
        // creates 4x5 (total 20) UIImageViews - two for each image
        
        let gridViewWidth = gridView.bounds.size.width
        let sideWidth = gridViewWidth / 4
        var horzCenter = sideWidth / 2
        var vertCenter = sideWidth / 2
        
        var imageNumber = 0
        // explanation immediately below
        
        for _ in 1...5 {
            for _ in 1...4 {
                if (imageNumber == 10) {
                    imageNumber = 0
                    // assigns one image to two UIImageViews
                }
                let imageView = UIImageView(image: images[imageNumber])
                // assigns an image to each UIImageView
                imageView.frame = CGRect(x: 0, y: 0, width: sideWidth - 8, height: sideWidth - 8)
                // I wanted there to be some space between the images.
                // ^ creating the size of UIImageViews for images
    
                let imageCenter = CGPoint(x: horzCenter, y: vertCenter)
                imageView.center = imageCenter
                // keeps track of UIImageView locations
                
                imageView.isUserInteractionEnabled = true
                // enabled for each so that tap function works
                //imageView.addGestureRecognizer(tapRecognizer)
                
                imageView.layer.cornerRadius = 8
                imageView.layer.masksToBounds = true
                // I felt like it
                
                gridView.addSubview(imageView)
                // adds UIImageView to UIView
                imageViews.append(imageView)
                // adds UIImageView to imageViews array
                // ^for further usage in basically everything
                imageCenters.append(imageCenter)
                // adds positions to imageCenters array
                // for usage in randomisation function
                
                imageNumber = imageNumber + 1
                horzCenter = horzCenter + sideWidth
                // moves position to create a row
            }
            vertCenter = vertCenter + sideWidth
            horzCenter = sideWidth / 2
            // moves position to create a new row beneath the previous
        }
        
        randomisePosition()
    }
    
    /*
    @objc func imageTappedFunction(gestureRecognizer: UITapGestureRecognizer) {
        //let tappedImage = gestureRecognizer.view! as! UIImageView
        print("tapped")
        
    }
 */
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //creates tap action for UIImageView
        let touch: UITouch = touches.first!
        
        if (touch.view != mainView) && (touch.view != gridView) {
            if (touch.view != scoresStackView) && (touch.view != buttonsStackView) {
                // ^ tap action only occurs when UIImageView is tapped
                // used to be something like
                // > if (imageViews.contains(touch.view as! UIImageView
                // ^ this was causing app to crash when anything other than a UIImageView
                // was tapped
                
                let tappedImage = touch.view as! UIImageView
                // something that took too long to work out
                
                if (imageViews.contains(touch.view as! UIImageView)) && (tapLock == 0) {
                    nImageTapped = imageViews.index(of: tappedImage)!
                    // shows the assigned image of UIImageView upon tap
                    
                    if (nImageTapped >= 10) {
                        nImageTapped = nImageTapped - 10
                    }
                    
                    tappedImage.image = images[nImageTapped]
                    
                    if (compareImages == 0) {
                        nFirstImageTapped = imageViews.index(of: tappedImage)!
                        compareImages = 1
                        // assigns the double-tap lock
                        
                        imageViews[nFirstImageTapped].isUserInteractionEnabled = false
                        // assigns lock to first image tapped
                    }
                    else {
                        nSecondImageTapped = imageViews.index(of: tappedImage)!
                        
                        if (abs(nFirstImageTapped - nSecondImageTapped) == 10) {
                            // absolute value used as there are 20 elements
                            // in imageViews but only 10 in images
                            
                            imageViews[nSecondImageTapped].isUserInteractionEnabled = false
                            // disables tap action upon correct match
                            
                            spinnyspin(image: nFirstImageTapped)
                            spinnyspin(image: nSecondImageTapped)
                            // animations for correct match
                            
                            imageViews[nFirstImageTapped].layer.borderWidth = 6
                            imageViews[nSecondImageTapped].layer.borderWidth = 6
                            imageViews[nFirstImageTapped].layer.borderColor = UIColor(named: "tcSeafoamGreen")!.cgColor
                            imageViews[nSecondImageTapped].layer.borderColor = UIColor(named: "tcSeafoamGreen")!.cgColor
                            // borders for imageviews upon correct match
                            
                            updateScore()
                            updateTotalScore()
                        }
                        else {
                            imageViews[nFirstImageTapped].isUserInteractionEnabled = true
                            // lock on first image removed
                            tapLock = 1
                            // tap lock for the spam-happy
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                self.imageViews[self.nFirstImageTapped].image = UIImage(named: "none.png")
                                self.imageViews[self.nSecondImageTapped].image = UIImage(named: "none.png")
                                // delayed to both give time and penalise time
                                // so that one cannot just randomly tap on everything
                                
                                self.tapLock = 0
                                // reverts tap lock
                            }
                            
                        }
                        compareImages = 0
                    }
                }
            }
        }
        
    }
    
    func spinnyspin(image: Int) {
        if (image == nFirstImageTapped) {
            direction = 1
        }
        else {
            direction = -1
        }
        
        UIView.animate(withDuration: 0.6) { () -> Void in
            self.imageViews[image].transform = CGAffineTransform(rotationAngle: CGFloat(3.14159 * Double(self.direction)))
        }
        UIView.animate(withDuration: 0.6, delay: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.imageViews[image].transform = CGAffineTransform(rotationAngle: CGFloat(3.14159 * 2 * Double(self.direction)))
        }, completion: nil)
    }

}

