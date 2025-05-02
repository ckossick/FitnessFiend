//
//  DBHelper.swift
//  FitnessFiend
//
//  Created by Courtney Kossick on 3/31/25.
//

import Foundation
import SQLite3

class DBHelper {
    static let shared = DBHelper()
    var db: OpaquePointer?
    var path: String = "myDb.sqlite"

    private init() {
        self.db = createDB()
        self.createTable()
    }
    
    struct Workout {
        var workout_id: Int
        var exercise: String
        var weight: Int
        var reps: Int
        var sets: Int
        var notes: String
    }
    
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
            print("Error creating DB")
            return nil
        }
        else {
            print("DB created successfully with path \(path)")
            return db
        }
    }
    
    func createTable() {
        let createQuery = """
        CREATE TABLE IF NOT EXISTS WorkoutEntry (
            workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise TEXT,
            weight INTEGER,
            reps INTEGER,
            sets INTEGER,
            notes TEXT
        )
        """

        var createTable: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, createQuery, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE {
                print("Table creation success")
            } else {
                print("Table creation fail")
            }
        } else {
            print("Preparation failed")
        }
        sqlite3_finalize(createTable)
    }

    func insert(exercise: String, weight: Any, reps: Any, sets: Any, notes: String) {
        let weightInt = Int("\(weight)") ?? 0
        let repsInt = Int("\(reps)") ?? 0
        let setsInt = Int("\(sets)") ?? 0

        let query = "INSERT INTO WorkoutEntry(exercise, weight, reps, sets, notes) VALUES (?, ?, ?, ?, ?)"
        var insert: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &insert, nil) == SQLITE_OK {
            sqlite3_bind_text(insert, 1, (exercise as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insert, 2, Int32(weightInt))
            sqlite3_bind_int(insert, 3, Int32(repsInt))
            sqlite3_bind_int(insert, 4, Int32(setsInt))
            sqlite3_bind_text(insert, 5, (notes as NSString).utf8String, -1, nil)

            if sqlite3_step(insert) == SQLITE_DONE {
                print("Insert successful")
            } else {
                print("Insert failed")
            }
        } else {
            print("Query preparation failed")
        }
        sqlite3_finalize(insert)
    }

    
    func delete(workoutId: Int) {
            let query = "DELETE FROM WorkoutEntry WHERE workout_id = ?"

            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(workoutId))

                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Successfully deleted workout with id: \(workoutId)")
                } else {
                    print("Error deleting workout.")
                }
            } else {
                print("Query preparation failed.")
            }
            sqlite3_finalize(statement)
        }
    
    func fetchWorkouts() -> [Workout] {
        var workouts: [Workout] = []
        let query = "SELECT workout_id, exercise, weight, reps, sets, notes FROM WorkoutEntry"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let workoutId = sqlite3_column_int(statement, 0)
                
                let exercise = sqlite3_column_text(statement, 1).map { String(cString: $0) } ?? ""
                let weight = Int(sqlite3_column_int(statement, 2))
                let reps = Int(sqlite3_column_int(statement, 3))
                let sets = Int(sqlite3_column_int(statement, 4))
                let notes = sqlite3_column_text(statement, 5).map { String(cString: $0) } ?? ""

                let workout = Workout(
                    workout_id: Int(workoutId),
                    exercise: exercise,
                    weight: weight,
                    reps: reps,
                    sets: sets,
                    notes: notes
                )

                workouts.append(workout)
            }
            sqlite3_finalize(statement)
        } else {
            print("SELECT query is not prepared")
        }

        return workouts
    }

    
    func update(workoutId: Int, newExercise: String, newWeight: Any, newReps: Any, newSets: Any, newNotes: String) {
        let weightInt = Int("\(newWeight)") ?? 0
        let repsInt = Int("\(newReps)") ?? 0
        let setsInt = Int("\(newSets)") ?? 0

        let query = "UPDATE WorkoutEntry SET exercise = ?, weight = ?, reps = ?, sets = ?, notes = ? WHERE workout_id = ?"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (newExercise as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(weightInt))
            sqlite3_bind_int(statement, 3, Int32(repsInt))
            sqlite3_bind_int(statement, 4, Int32(setsInt))
            sqlite3_bind_text(statement, 5, (newNotes as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(workoutId))

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated workout with id: \(workoutId)")
            } else {
                print("Update failed.")
            }
        } else {
            print("Query preparation failed.")
        }

        sqlite3_finalize(statement)
    }
    
    func fetchWorkoutsFiltered(byExercise exerciseFilter: String) -> [Workout] {
        var workouts: [Workout] = []
        let query = "SELECT workout_id, exercise, weight, reps, sets, notes FROM WorkoutEntry WHERE exercise = ?"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (exerciseFilter as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let workoutId = sqlite3_column_int(statement, 0)
                let exercise = sqlite3_column_text(statement, 1).map { String(cString: $0) } ?? ""
                let weight = sqlite3_column_int(statement, 2)
                let reps = sqlite3_column_int(statement, 3)
                let sets = sqlite3_column_int(statement, 4)
                let notes = sqlite3_column_text(statement, 5).map { String(cString: $0) } ?? ""

                workouts.append(Workout(workout_id: Int(workoutId), exercise: exercise, weight: Int(weight), reps: Int(reps), sets: Int(sets), notes: notes))
            }
        } else {
            print("Filtered SELECT query not prepared")
        }
        
        sqlite3_finalize(statement)
        return workouts
    }
    
    func fetchExerciseStats(for exerciseFilter: String) -> (maxWeight: Int, avgReps: Double, avgSets: Double)? {
        let query = """
        SELECT 
            MAX(CAST(weight AS INTEGER)), 
            AVG(CAST(reps AS FLOAT)), 
            AVG(CAST(sets AS FLOAT)) 
        FROM WorkoutEntry 
        WHERE exercise = ?
        """
        
        var statement: OpaquePointer? = nil
        var result: (Int, Double, Double)? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (exerciseFilter as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let maxWeight = sqlite3_column_int(statement, 0)
                let avgReps = sqlite3_column_double(statement, 1)
                let avgSets = sqlite3_column_double(statement, 2)
                result = (Int(maxWeight), round(avgReps * 100) / 100, round(avgSets * 100) / 100)
            }
        } else {
            print("Stats query not prepared")
        }

        sqlite3_finalize(statement)
        return result
    }
}
