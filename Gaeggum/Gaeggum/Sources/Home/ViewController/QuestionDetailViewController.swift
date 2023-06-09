//
//  QuestionDetailViewController.swift
//  Gaeggum
//
//  Created by zeroStone ⠀ on 2022/05/23.
//

import UIKit

class QuestionDetailViewController: UIViewController{
    var userInfoDelegate: UserInfoDelegate?
    
    var answerStats : [Stat] = []
    
    var nowTestPaperIndex = 0
    lazy var nowTestPaper : TestPaper = {return dummyTestPaper[nowTestPaperIndex]}()
    var nowUserStat : Stat = Stat(data: 0, system: 0, userFriendly: 0, math: 0, collaboration: 0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // property 전달 test
//        print(nowTestPaperIndex, nowTestPaper, nowUserStat, separator: "\n")
        
        let testPaperStackView = makeStackView()
        self.view.addSubview(testPaperStackView)
        testPaperStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        testPaperStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        testPaperStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 50).isActive = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func makeStackView()->UIStackView {
        lazy var stackView: UIStackView = {
            let stackV = UIStackView()
            stackV.translatesAutoresizingMaskIntoConstraints = false
            stackV.axis = .vertical
            stackV.spacing = 10
            stackV.distribution = .fillProportionally
            
            return stackV
        }()

        let nowTestPaper = dummyTestPaper[nowTestPaperIndex]
        let questionText = nowTestPaper.question
        
        // 질문 헤더 세팅
        let questionHeaderView = QuestionHeaderView()
        questionHeaderView.updateQuestionHeader(index: nowTestPaperIndex + 1, dummyArrayLength: dummyTestPaper.count, questionText:questionText)
        stackView.addArrangedSubview(questionHeaderView)
//        questionHeaderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 50).isActive = true
        
        // make alphabets array
        let aScalars = "A".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        let alphabets: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }
        
        for (answerIndex, (answerText,stat)) in nowTestPaper.answer.enumerated() {
            lazy var answerView: UIButton = {
                
                let headedAnswerText = String(alphabets[answerIndex]) + ". " + answerText

//                var config = UIButton.Configuration.gray()
//
//                config.baseBackgroundColor = .systemGray5
//                config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
//                config.title = headedAnswerText
                

                
                let button = UIButton(type: .custom)
                
                button.tag = answerIndex // put button id to recognize question index
                button.setTitle(headedAnswerText, for: .normal)
                button.titleLabel?.numberOfLines = 0
                button.titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                button.backgroundColor = .systemGray5
                button.setTitleColor(.black, for: .normal)
                button.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false
                
                
                button.contentEdgeInsets = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)
                return button
            }()
            
            stackView.addArrangedSubview(answerView)
            
            
            answerStats.append(stat)
        }
        
        return stackView
        
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        let nextTestPaperIndex = self.nowTestPaperIndex + 1
        var nextUserStat : Stat = Stat()
        
        let tappedAnswerStat : Stat = nowTestPaper.answer[sender.tag].1
        nextUserStat.addStat(answerStat: tappedAnswerStat)
        nextUserStat.addStat(answerStat: self.nowUserStat)
        
        if nextTestPaperIndex >= dummyTestPaper.count {
            // 모든 질문 끝났을 때
            userInfoDelegate?.statUpdated(stat: nextUserStat)
            dismiss(animated: true)
        } else {
            // 안 끝났을 때
            let storyboard = UIStoryboard(name: "QuestionDetail", bundle: nil)
            guard let nextQuestionDetailViewController = storyboard.instantiateViewController(withIdentifier: "QuestionDetailVC") as? QuestionDetailViewController else { return }
            
            nextQuestionDetailViewController.nowTestPaperIndex = nextTestPaperIndex
            nextQuestionDetailViewController.nowUserStat = nextUserStat
            nextQuestionDetailViewController.userInfoDelegate = self.userInfoDelegate
            
            // 화면 전환 애니메이션 설정
            nextQuestionDetailViewController.modalTransitionStyle = .coverVertical
    //                secondViewController.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(nextQuestionDetailViewController, animated: true)
            
        }
    }
        
}

