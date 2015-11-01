import Foundation

class MainScene: CCNode {

    weak var levelSelectButton: CCButton!
    weak var testPlayButton: CCButton!
    
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
    }
    
    func levelSelect() {
        let levelSelectScene = CCBReader.loadAsScene("LevelSelect")
        CCDirector.sharedDirector().presentScene(levelSelectScene)
    }
    
    func testPlay() {
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
}
