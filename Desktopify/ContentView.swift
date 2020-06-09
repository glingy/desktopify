//
//  ContentView.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    var desktops: [Desktop]
    var body: some View {
        List(desktops, id: \.name) { desktop in
            DesktopView(desktop: desktop)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.deleteDisabled(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
    }
}

/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let desktops = [
            Desktop(path: URL(fileURLWithPath: "helloo"), key: nil),
            Desktop(path: URL(fileURLWithPath: "hello2"), key: 4),
            Desktop(path: URL(fileURLWithPath: "hellooo"), key: 0),
            Desktop(path: URL(fileURLWithPath: "hello22"), key: 2)
        ]
        return ContentView(desktops: desktops)
    }
}*/

