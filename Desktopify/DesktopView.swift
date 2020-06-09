//
//  DesktopView.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import SwiftUI

struct DisplayKey {
    let name : String
    let keyCode : Int
}

let DISPLAY_KEY_MAP : [DisplayKey] = [
    DisplayKey(name: "None", keyCode: 0),
    DisplayKey(name: "F1",   keyCode: 122),
    DisplayKey(name: "F2",   keyCode: 120),
    DisplayKey(name: "F3",   keyCode: 99),
    DisplayKey(name: "F4",   keyCode: 118),
    DisplayKey(name: "F5",   keyCode: 96),
    DisplayKey(name: "F6",   keyCode: 97),
    DisplayKey(name: "F7",   keyCode: 98),
    DisplayKey(name: "F8",   keyCode: 100),
    DisplayKey(name: "F9",   keyCode: 101),
    DisplayKey(name: "F10",  keyCode: 109),
    DisplayKey(name: "F12",  keyCode: 111)
]

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
