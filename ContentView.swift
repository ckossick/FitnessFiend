//
//  ContentView.swift
//  FitnessFiend
//
//  Created by Courtney Kossick on 10/25/24.
//



/* PENDING FEATURES
 *
 * ~Make profile picture become permanent
 * ~Use data from profile to provide more insights into health
 * ~Film more/better videos
 * ~Make video page better organized
 * ~Make journal store data better, either work with SQL or
 * write to a .txt file, so workout can be accessed at a later date
 * ~Make calendar color changing, set workouts for specific dates
 * ~Add times to workout scheduled in advanced and send notifications
 * ~Hold milestones in calendar
 *
 */


import SwiftUI
import PhotosUI
import AVKit
import Foundation


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            self.hideKeyboard()
        }
    }
}

extension Color {
    init(hex: String) {
        //light green: #84d59f
        //yellow: #ecf18c
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                VStack {
                    Text("Fitness Fiend")
                        .font(.system(size: 40))
                        .padding()
                        .foregroundColor(.black)
                        .frame(width: 300, height: 70, alignment: .center)
                        .background(Color(hex: "#b0ff83"))
                        .cornerRadius(8)
                        .border(Color.black, width: 2)
                    Text("An app to empower and educate women in their weightlifting experience")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 19))
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 370, height: 80, alignment: .top)
                        .background(Color(hex: "#d6ffbf"))
                        .cornerRadius(8)
                        .border(Color.black, width: 2)
                    Text("")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20))
                        .padding()
                        .cornerRadius(8)
                        .frame(width: 370, height: 10, alignment: .top)
                    
                    ZStack {
                        NavigationLink(destination: Profile()) {
                            ZStack{
                                Image(systemName: "Profile")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                                    .frame(width:150, height: 150)
                                    .background(Color(.white))
                                    .clipShape(Circle())
                                    .overlay(
                                        VStack {
                                            Image(systemName: "person")
                                                .font(.system(size: 110))
                                                .foregroundColor(.black)
                                            Text("Profile")
                                                .foregroundStyle(Color.black)
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 15))
                                        }
                                    )
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                        }
                    }
                    Text("")
                        .multilineTextAlignment(.center)
                        .frame(width: 370, height: 5, alignment: .top)
                        .font(.system(size: 10))
                        .padding()
                        .cornerRadius(8)

                    NavigationLink(destination: ExerciseGuide()) {
                        Text("Exercise Guide")
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 100)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .border(Color.black, width: 2)
                    }
                    Text("")
                        .multilineTextAlignment(.center)
                        .frame(width: 370, height: 0)
                        .font(.system(size: 5))
                    
                    NavigationLink(destination: WorkoutTracker()) {
                        Text("Workout Tracker")
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 100)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .border(Color.black, width: 2)
                    }
                        
                    /*Text("")
                        .multilineTextAlignment(.center)
                        .frame(width: 370, height: 0)
                        .font(.system(size: 5))
                    
                    NavigationLink(destination: BiologyMyths()) {
                        Text("Biology Does NOT Define You!")
                            .foregroundColor(.black)
                            .font(.system(size: 25))
                            .padding()
                            .frame(width: 300, height: 100)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                            .border(Color.black, width: 2)
                    }*/
                    Text("")
                        .multilineTextAlignment(.center)
                        .frame(width: 370, height: 0)
                        .font(.system(size: 5))
                }
            }
        }
    }
}


struct Profile : View {
    @AppStorage("savedTextFieldValueName") private var name: String = ""
    @AppStorage("savedTextFieldValueAge") private var age: String = ""
    @AppStorage("savedTextFieldValueHeight") private var height: String = ""
    @AppStorage("savedTextFieldValueWeight") private var weight: String = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                ZStack {
                    Text(" ")
                        .frame(width: 500, height: 290)
                        .background(Color(hex: "#d6ffbf"))
                        .border(Color.black, width: 2)
                    VStack {
                        avatarImage?
                            .resizable()
                                .frame(width:150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            Text(" ")
                                .frame(width: 200, height: 20)
                            ZStack {
                                Text(" ")
                                    .frame(width: 200, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                
                                PhotosPicker("Select profile picture", selection: $avatarItem, matching: .images)
                                    .padding(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.black, lineWidth: 2)
                                            .frame(width: 200, height: 40)
                                    )
                                    .padding()
                            }
                            
                        }
                        .onChange(of: avatarItem) {
                            Task {
                                if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                                    avatarImage = loaded
                                    
                                } else {
                                    print("Failed")
                                }
                            }
                        }
                    }
                    
                    Text("")
                        .frame(width: 250, height: 30)
                    ZStack {
                        Text(" ")
                            .frame(width: 500, height: 70)
                            .background(Color(hex: "#d6ffbf"))
                            .border(Color.black, width: 2)
                        HStack {
                            Text("Name:")
                            Text(" ")
                                .frame(width: 2)
                            TextField(text: $name, prompt: Text("Please Enter Your Name").font(.system(size: 15))) {
                                Text("")
                            }
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 285, height: 32)
                            )
                            .padding()
                            .frame(width: 325, height: 15)
                        }
                    }
                    Text("")
                        .frame(width: 250, height: 15)
                    
                    ZStack {
                        Text(" ")
                            .frame(width: 500, height: 70)
                            .background(Color(hex: "#d6ffbf"))
                            .border(Color.black, width: 2)
                        HStack {
                        Text("Age:")
                        Text("  ")
                            .frame(width: 20)
                        TextField(text: $age, prompt: Text("Please Enter Your Age").font(.system(size: 15))) {
                            Text("")
                        }
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 285, height: 32)
                        )
                        .padding()
                        .frame(width: 325, height: 15)
                        }
                    }
                    
                    Text("")
                        .frame(width: 250, height: 15)
                    
                    ZStack {
                        Text(" ")
                            .frame(width: 500, height: 70)
                            .background(Color(hex: "#d6ffbf"))
                            .border(Color.black, width: 2)
                        HStack {
                            Text("Height:")
                            Text(" ")
                                .frame(width: 2)
                            TextField(text: $height, prompt: Text("Please Enter Your Height (in inches)").font(.system(size: 15))) {
                                Text("")
                            }
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 285, height: 32)
                            )
                            .padding()
                            .frame(width: 325, height: 15)
                        }
                    }
                    
                    Text("")
                        .frame(width: 250, height: 15)
                    
                    ZStack {
                        Text(" ")
                            .frame(width: 500, height: 70)
                            .background(Color(hex: "#d6ffbf"))
                            .border(Color.black, width: 2)
                        HStack {
                            Text("Weight:")
                            Text("")
                            TextField(text: $weight, prompt: Text("Please Enter Your Weight (in pounds)").font(.system(size: 15))) {
                                Text("")
                            }
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 285, height: 32)
                            )
                            .padding()
                            .frame(width: 325, height: 15)
                        }
                        
                    }
                }.textFieldStyle(.roundedBorder)
            }
        }
    }




struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Only allow image selection
        configuration.selectionLimit = 1 // Limit selection to one item

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

struct ExerciseGuide : View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                Text("Exercise Guide")
                    .font(.system(size: 50))
                    .padding()
                    .foregroundColor(.black)
                    .frame(width: 350, height: 85, alignment: .center)
                    .background(Color(hex: "#b0ff83"))
                    .cornerRadius(8)
                    .border(Color.black, width: 2)
                Text("")
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 30, height: 75)
                HStack {
                    NavigationLink(destination: UpperBody()) {
                        Text("Upper Body")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                            .border(Color.black, width: 2)
                    }
                    Text("")
                        .font(.system(size: 25))
                        .padding()
                        .frame(width: 30, height: 30)
                    NavigationLink(destination: LowerBody()) {
                        Text("Lower Body")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                            .border(Color.black, width: 2)
                    }
                }
                Text("")
                    .font(.system(size: 15))
                    .padding()
                    .frame(width: 30, height: 30)
                HStack {
                    NavigationLink(destination: Core()) {
                        Text("Core")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                            .border(Color.black, width: 2)
                    }
                    /*Text("")
                        .font(.system(size: 25))
                        .padding()
                        .frame(width: 30, height: 30)
                    NavigationLink(destination: Cardio()) {
                        Text("Cardio")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                    }*/
                }
            }
        }
    }
}

struct UpperBody : View {
    @State private var player = AVPlayer()
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                Text("Lat Pulldown")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .padding()
                    .frame(width: 200, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3565", withExtension: "MOV")!))
                    .edgesIgnoringSafeArea(.all)
                Text("Cable Pulldown")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .padding()
                    .frame(width: 375, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3567", withExtension: "MOV")!))
                    .edgesIgnoringSafeArea(.all)
                Text("Hammer Curls")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .padding()
                    .frame(width: 375, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3569", withExtension: "MOV")!))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct LowerBody : View {
    @State private var player = AVPlayer()
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
            Text("Leg Press")
                .foregroundColor(.black)
                .font(.system(size: 30))
                .padding()
                .frame(width: 200, height: 40)
                .background(Color.white)
                .cornerRadius(8)
                .multilineTextAlignment(.center)
            VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3570", withExtension: "MOV")!))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct Core : View {
    @State private var player = AVPlayer()
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                Text("Crunches")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .padding()
                    .frame(width: 200, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3571", withExtension: "MOV")!))
                    .edgesIgnoringSafeArea(.all)
                Text("Planks (Straight Arm and Elbow)")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .padding()
                    .frame(width: 375, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                VideoPlayer(player: AVPlayer(url:Bundle.main.url(forResource: "IMG_3572", withExtension: "MOV")!))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

/*struct Cardio : View {
    var body: some View {
        Text("Cardio Workouts Coming Soon!")
    }
}*/


//The page that allows users to pick how they want to track their workouts, between calendar and journal
struct WorkoutTracker : View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                Text("How would you like to track your workouts?")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .padding()
                    .frame(width: 350, height: 150)
                    .background(Color(hex: "#b0ff83"))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .border(Color.black, width: 2)
                Text("\n")
                    .font(.system(size: 40))
                NavigationLink(destination: Journal()) {
                    Text("Workout Journal")
                        .foregroundColor(.black)
                        .font(.system(size: 40))
                        .padding()
                        .frame(width: 300, height: 150)
                        .background(Color(hex: "#fcffba"))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                }
                Text("\n")
                    .font(.system(size: 15))
                NavigationLink(destination: CalendarView()) {
                    Text("Workout Calender")
                        .foregroundColor(.black)
                        .font(.system(size: 40))
                        .padding()
                        .frame(width: 300, height: 150)
                        .background(Color(hex: "#fcffba"))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                }
            }
        }
    }
}

//A journal to allow users to add and track their workouts, including weight lifted
struct Journal: View {
    @State private var exercise = ""
    @State private var weight = ""
    @State private var reps = ""
    @State private var sets = ""
    @State private var notes = ""
    @State private var workouts: [DBHelper.Workout] = []
    @State private var editingWorkout: DBHelper.Workout? = nil
    @State private var filterText = ""
    @State private var stats: (maxWeight: Int, avgReps: Double, avgSets: Double)? = nil

    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Group {
                    TextField("Enter Exercise", text: $exercise)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Weight", text: $weight)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Reps", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Sets", text: $sets)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(editingWorkout == nil ? "Add Workout" : "Update Workout") {
                    let weightInt = Int(weight) ?? 0
                    let repsInt = Int(reps) ?? 0
                    let setsInt = Int(sets) ?? 0
                    
                    if let workout = editingWorkout {
                        DBHelper.shared.update(
                            workoutId: workout.workout_id,
                            newExercise: exercise,
                            newWeight: weightInt,
                            newReps: repsInt,
                            newSets: setsInt,
                            newNotes: notes
                        )
                        editingWorkout = nil
                    } else {
                        DBHelper.shared.insert(
                            exercise: exercise,
                            weight: weightInt,
                            reps: repsInt,
                            sets: setsInt,
                            notes: notes
                        )
                    }
                    
                    clearInputs()
                    workouts = DBHelper.shared.fetchWorkouts()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                
                HStack {
                    TextField("Filter by Exercise", text: $filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Apply Filter") {
                        if filterText.isEmpty {
                            workouts = DBHelper.shared.fetchWorkouts()
                        } else {
                            workouts = DBHelper.shared.fetchWorkoutsFiltered(byExercise: filterText)
                            stats = DBHelper.shared.fetchExerciseStats(for: filterText)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                Button("Clear Filter") {
                    filterText = ""
                    workouts = DBHelper.shared.fetchWorkouts()
                    stats = nil
                }
                .foregroundColor(.red)
                
                if let stats = stats {
                    Text("Max Weight: \(stats.maxWeight) lbs")
                    Text("Avg Reps: \(String(format: "%.2f", stats.avgReps))")
                    Text("Avg Sets: \(String(format: "%.2f", stats.avgSets))")
                }
                
                List {
                    ForEach(workouts, id: \.workout_id) { workout in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Exercise: \(workout.exercise)").bold()
                            Text("Weight: \(workout.weight)")
                            Text("Reps: \(workout.reps)")
                            Text("Sets: \(workout.sets)")
                            Text("Notes: \(workout.notes)")
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    exercise = workout.exercise
                                    weight = "\(workout.weight)"
                                    reps = "\(workout.reps)"
                                    sets = "\(workout.sets)"
                                    notes = workout.notes
                                    editingWorkout = workout
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: {
                                    DBHelper.shared.delete(workoutId: workout.workout_id)
                                    workouts = DBHelper.shared.fetchWorkouts()
                                    editingWorkout = nil
                                    clearInputs()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear {
            workouts = DBHelper.shared.fetchWorkouts()
        }
        .dismissKeyboardOnTap()
    }

    func clearInputs() {
        exercise = ""
        weight = ""
        reps = ""
        sets = ""
        notes = ""
    }
}


/*struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black, lineWidth: 3)
            ).padding()
            .background(Color.white).lineLimit(20, reservesSpace: true)
    }
}*/
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ScheduleItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String?
}

struct CalendarViewModel: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String?
    var items: [ScheduleItem]
}

struct CalendarView: View {
    let days = [
        "Su","M","Tu","W","Th","F","Sa"
    ]
    let columns = [
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center),
        GridItem(.fixed(44), spacing: 13, alignment: .center)
    ]
    
    let color = Color.white
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            Text(" ")
                .frame(width: 500, height: 500)
                .background(Color(hex: "#d6ffbf"))
                .border(Color.black, width: 2)
            VStack {
                Text("December 2024")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .padding()
                    .frame(width: 200, height: 70)
                    .background(Color(hex: "#b0ff83"))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .border(Color.black, width: 2)
                Text(" ")
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .padding()
                    .frame(width: 175, height: 40)
                LazyVGrid(columns: columns) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .padding()
                            .font(.system(size: 9))
                            .frame(width: 50, height: 50)
                            .background(Color(hex: "#fcffba"))
                            .cornerRadius(8)
                            .border(Color.black, width: 2)
                        
                    }
                    ForEach(1..<32) { day in
                        HStack {
                            Button(action: colorChange) {
                                Text("\(day)")
                                    .padding()
                                    .font(.system(size: 10))
                                    .frame(width: 50, height: 50)
                                    .background(color)
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.center)
                            }
                            /*Text("\(day)")
                                .padding()
                                .font(.system(size: 10))
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .cornerRadius(8)
                                .multilineTextAlignment(.center)*/
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .border(Color.black, width: 2)
                    }
                }
            }
        }
    }
    func colorChange() {
        let color = Color.red
        print("\(color)")
    }
}

/*
func dayOfMonth(integer: Int) -> String {
    return "Hello, World!"
}
                                               
struct day1 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day2 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day3 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day4 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day5 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day6 : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct day7 : View {
    var body: some View {
        Text("Hello, World!")
    }
} */

struct BiologyMyths : View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Text("Myth Busting Ideas Around Weightlifting For Women")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .padding()
                        .frame(width: 350, height: 150)
                        .background(Color(hex: "#b0ff83"))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                    Spacer(minLength: 20)
                    Text("Myth: Lifting will make me \"manly\"\n\nBusted: This is one of the most common gym related myths. Some of this is connected to the fact that lifting weights, like any form of exercise, does increase testosterone levels. However, both men and women do have naturally occurring testosterone in their bodies, and even temporarily heightened testosterone levels do not indicate that someone is a man. The other thought that many women have when it comes to this myth is that they are afraid of getting \"bulky\", a physical look that is commonly associated with manliness. Significant muscle gain is not something that happens overnight, and if you feel that you are gaining \"too much muscle\", there is the opportunity to change course, to better target your physical goals. Achieving the bodybuilder physique that is so commonly seen on social media takes years of dedicated training, and is often reached through the use of performance-enhancing drugs, such as steroids. For the average woman who wants to stay healthy, weight lifting will generally lead to a more toned look, as opposed to a \"bulky\" appearance.")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding()
                        .frame(width: 350, height: 870)
                        .background(.white)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                    Text("Myth: Women can't lift while on their periods/while pregnant. \n\nBusted: Under typical circumstances, weightlifting while on your period or pregnant is safe. In fact, exercising while pregnant has been shown to limit pain caused by menstrual cramps. Additionally, according to the American College of Obstetricians and Gynecologists, \"Physical activity and exercise in pregnancy are associated with minimal risks and have been shown to benefit most women, although some modification to exercise routines may be necessary because of normal anatomic and physiologic changes and fetal requirements\". However, it is always best to talk with a doctor, especially if you were not weightlifting consistently prior to becoming pregnant.")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding()
                        .frame(width: 350, height: 585)
                        .background(.white)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                    Text("Myth: Women can't lift as much as men. \n\nBusted: Although it is true that the average man does have a greater muscle mass than the average woman, this does not mean that a woman cannot be as strong as a man. That is dependent on training level. As per an article published in the Canadian Journal of Applied Physiology, \"The best-trained women can out-perform sedentary men\". It is also important to note that \"The handicap of the average woman is offset by a lighter body mass and a tendency to metabolize fat rather than carbohydrate during exercise\"")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding()
                        .frame(width: 350, height: 500)
                        .background(.white)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                    Text("Myth: Weightlifting won't help me lose weight. \n\nBusted: The biggest key to weight loss is a greater calorie output than calorie intake. On average, cardiovascular exercise does burn more calories within a given time than weightlifting. However, all forms of exercise will still burn calories, contributing to weight loss. Additionally, according to the research reported in the article Lift weights to fight overweight, weightlifting does raise metabolic rates, contributing to how quickly calories get burned by the body. In the end, a combination of diet and exercise, in the forms of weightlifting, cardio, or both, will be the keys to achieving weight loss goals.")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding()
                        .frame(width: 350, height: 560)
                        .background(.white)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .border(Color.black, width: 2)
                }
            }
            .frame(height: 700)
        }
    }
}


#Preview {
    ContentView()
}
