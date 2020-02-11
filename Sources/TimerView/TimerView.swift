//
//  TimerView.swift
//  TimerView-master
//
//  Created by Viktor Maric on 2020. 02. 11..
//  Copyright © 2020. Viktor Maric. All rights reserved.
//

import SwiftUI
import AVFoundation

@available(OSX 10.15, *)
@available(iOS 13.0, *)

/// Timer appearing at the bottom of a View.
public struct TimerView: View {
    
//    MARK: - variables, constants
    @Binding var showTimer: Bool
    @Binding var timerValue: Int
    var backgroundColor: Color
    var vibrationAtTheEnd: Bool
    
    @State private var time = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var dateLockingScreen = Date()
    
    public init(showTimer: Binding<Bool>, timerValue: Binding<Int>, backgroundColor: Color, vibrationAtTheEnd: Bool) {
        self._showTimer = showTimer
        self._timerValue = timerValue
        self.backgroundColor = backgroundColor
        self.vibrationAtTheEnd = vibrationAtTheEnd
    }
    
//    MARK: - UI
    public var body: some View {
        
        VStack {
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if self.timerValue - 15 > 0 {
                                self.timerValue -= 15
                            } else {
                                self.timerValue = 0
                            }
                        }
                    }) {
                        Image(systemName: "gobackward.15")
                    }
                    .font(.system(size: 24, weight: .medium))
                    .padding(.horizontal, 50)
                    
                    ZStack {
                        Circle()
                            .trim()
                            .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 6)
                            .frame(width: 100, height: 100)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(timerValue)/CGFloat(time))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                            .frame(width: 100, height: 100)
                            .rotationEffect(Angle(degrees: -90))
                        
                        Text(timeString(time: Double(self.timerValue)))
                            .frame(width: 60)
                            .animation(nil)
                            .onReceive(timer) { _ in
                                if self.timerValue > 0 {
                                    withAnimation(.linear(duration: 1.0)) {
                                        self.timerValue -= 1
                                    }
                                } else {
                                    if self.vibrationAtTheEnd {
                                        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
                                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                        }
                                    }
                                    
                                    withAnimation {
                                        self.showTimer = false
                                    }
                                }
                        }
                        
                    }
                    
                    Button(action: {
                        withAnimation {
                            self.timerValue += 15
                            if self.timerValue > self.time {
                                self.time += 15
                            }
                        }
                    }) {
                        Image(systemName: "goforward.15")
                    }
                    .font(.system(size: 24, weight: .medium))
                    .padding(.horizontal, 50)
                    
                    Spacer()
                }
                
                Button(action: {
                    withAnimation {
                        self.showTimer = false
                    }
                }) {
                    Text("Skip")
                }
                .padding(.top)
            }
            .padding(.top)
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
        }
        .onAppear() {
            self.time = self.timerValue
        }
        .transition(.move(edge: .bottom))
        
        
    }
    
    /// Converts Int (time) to string.
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        return String(format: "%02i:%02i", minute, second)
    }
    
    
}
