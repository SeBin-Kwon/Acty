//
//  HomeViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation
import Combine

final class HomeViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    
    struct Input {
        var onAppear = PassthroughSubject<Bool, Never>()
    }
    
    struct Output {
        
    }
    
    init() {
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                
            }
            .store(in: &cancellables)
    }
}
