//
//  MidoriApp.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import SwiftUI

@main
struct MidoriBudgetApp: App {
    var body: some Scene {
        WindowGroup {
            CardListView()
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
