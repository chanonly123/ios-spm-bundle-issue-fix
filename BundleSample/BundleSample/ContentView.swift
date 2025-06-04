//
//  ContentView.swift
//  BundleSample
//
//  Created by Chandan Karmakar on 04/06/25.
//

import SwiftUI
import MyLib
import Combined

struct ContentView: View {
    var body: some View {
        VStack {
            Image.init("ic_Combined", bundle: Combined.bundle)
                .resizable()
                .frame(width: 30, height: 30)
            Image.init("ic_MyLib", bundle: MyLib.bundle)
                .resizable()
                .frame(width: 30, height: 30)
            Text(MyLib.value)
        }
        .padding()
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}
