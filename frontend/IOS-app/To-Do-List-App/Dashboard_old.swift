//
//  Dashboard_old.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 26/05/2024.
//

import SwiftUI




struct iOSCheckboxToggleStyle: ToggleStyle{
    func makeBody(configuration: Configuration) -> some View {
        Button(action:{
            configuration.isOn.toggle()
        }
               , label: {
            HStack{
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                
                configuration.label
            }
        })
    }
}

#Preview {
    Dashboard_old()
}
