//
//  ViewModelProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/1/25.
//


import Foundation

/// 모든 ViewModel이 채택할 공통 프로토콜
/// Action(입력)과 State(출력)의 흐름을 통일시켜주는 역할을 합니다.
protocol ViewModelProtocol {
    /// ViewModel에 전달될 사용자 입력 또는 이벤트
    associatedtype Action
    
    /// View에 필요한 모든 데이터를 담고 있는 단일 상태 객체
    associatedtype State
    
    /// View로부터 Action을 받아 처리하는 클로저
    var action: ((Action) -> Void)? { get }
    
    /// View가 구독할 현재 State 값
    var state: State { get }
}
