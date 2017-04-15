//
//  holeOne.swift
//  Putt
//
//  Created by Tom Wicks on 18/03/2017.
//  Copyright © 2017 Tom Wicks. All rights reserved.
//

import SpriteKit

class holeOne: SKScene, SKPhysicsContactDelegate {
    
    enum CollisionTypes:UInt32{
        case type1 = 1
        case type2 = 2
    }
    
    let BallCategoryName = "ball"
    
    var isFingerOnBall = false
    
    var impulseX:CGFloat = 0
    var impulseY:CGFloat = 0
    
    var borderBody:SKPhysicsBody!
    var powerLine:SKShapeNode!
    
    var myScoreLabel: SKLabelNode!
    var myscore:Int = 0
    
    var opponentScore:Int = 10
    
    var seconds = 6 //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    
    override func sceneDidLoad() {
    
        super.sceneDidLoad()
        physicsWorld.speed = 0.9
        physicsWorld.contactDelegate = self
        
        self.scaleMode = SKSceneScaleMode.resizeFill
        borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        borderBody.restitution = 0.7

        
        physicsBody = borderBody
        
        powerLine = SKShapeNode()
        powerLine.lineWidth = 9
        powerLine.strokeColor = SKColor(red: 69.0/255, green: 129.0/255, blue: 129.0/255, alpha: 1.0)
        powerLine.lineCap = CGLineCap.round
        powerLine.zPosition = 0
        
        self.addChild(powerLine)
        
        runTimer()
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        
        if seconds < 1 {
            timer.invalidate()
            if myscore > opponentScore {
                print("Winner")
            }
            
            else {
                print("Loser")
                let reveal = SKTransition.reveal(with: .down,
                                                 duration: 1)
                let newScene = loserScene(size: CGSize(width: 1024, height: 768))
                
                scene?.view?.presentScene(newScene,
                                        transition: reveal)
            }
            
        } else {
            seconds -= 1    //This will decrement(count down)the seconds.
            if let timerLabel = self.childNode(withName: "timerLabel") as? SKLabelNode {
                timerLabel.text = timeString(time: TimeInterval(seconds))
            }
        }
    }


    override func didMove(to view: SKView) {
        
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        ball.physicsBody!.categoryBitMask = 1
        ball.physicsBody!.collisionBitMask = 1
        
        let hole = childNode(withName: "goal-1") as! SKSpriteNode
        hole.physicsBody!.categoryBitMask = 1
        hole.physicsBody!.contactTestBitMask =  1
        hole.physicsBody!.collisionBitMask = 1
    }
    
    func addScore() {
        myscore += 1
        if let myScoreLabel = self.childNode(withName: "myScoreLabel") as? SKLabelNode {
            myScoreLabel.text = "\(myscore)"
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        addScore()
        
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
        let absDx = abs(ball.physicsBody!.velocity.dx)
        let absDy = abs(ball.physicsBody!.velocity.dy)
        
        print("X:\(absDx)")
        print("Y:\(absDy)")
    
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
        if abs(ball.physicsBody!.velocity.dx) > CGFloat(50) ||
            abs(ball.physicsBody!.velocity.dy) > CGFloat(50) {
            return
        }
        
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == BallCategoryName {
                isFingerOnBall = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
            impulseX = (ball.position.x - touchLocation.x) * 8
            impulseY = (ball.position.y - touchLocation.y) * 8
            let impulseXLine = (ball.position.x - touchLocation.x) * 2
            let impulseYLine = (ball.position.y - touchLocation.y) * 2
            
            let powerPath = CGMutablePath()
            powerPath.move(to: CGPoint(x:ball.position.x,
                                       y:ball.position.y))
            powerPath.addLine(to: CGPoint(x:ball.position.x + impulseXLine,
                                          y:ball.position.y + impulseYLine))
            powerLine.path = powerPath
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            let ball = childNode(withName: "ball")!
            ball.physicsBody?.applyImpulse(CGVector(dx: impulseX, dy: impulseY))
            print("hhg jhg \(impulseX),\(impulseY)")
            isFingerOnBall = false
            powerLine.path = nil
        
    }
}
