//
//  DesktopView.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import SwiftUI







struct DesktopView: View {
    @ObservedObject var desktop: Desktop
    
    
    var body: some View {
        HStack {
            Text(desktop.name)
                .padding()
            Spacer()
            Picker(selection: $desktop.key, label: Text("Shortcut:")) {
                ForEach(DISPLAY_KEY_MAP, id: \.keyCode) { i in
                    Text(i.name)
                }
            }.frame(width: 150, height: nil, alignment: .trailing)
        }
    }
}
