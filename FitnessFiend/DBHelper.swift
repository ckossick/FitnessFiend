//
//  DBHelper.swift
//  FitnessFiend
//
//  Created by Courtney Kossick on 3/31/25.
//

import Foundation
import SQLite3
import SQLite

class DBHelper {
    static let shared = DBHelper()
    var db: OpaquePointer?
    
    var ormDB: Connection?
    let workoutTable = Table("WorkoutEntry")
    let workoutId = Expression<Int>("workout_id")
    let exerciseCol = Expression<String>("exercise")
    let weightCol = Expression<Int>("weight")
    let repsCol = Expression<Int>("reps")
    let setsCol = Expression<Int>("sets")
    let notesCol = Expression<String>("notes")
    
    private init() {
        self.db = createDB()
        self.createTable()
        self.createIndexes()
    }
    
    func createDB() -> OpaquePointer? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let dbURL = paths[0].appendingPathComponent("workouts.db")

        do {
            ormDB = try Connection(dbURL.path)
        } catch {
            print("ORM DB connection failed: \(error)")
        }

        var db: OpaquePointer? = nil
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        print("Successfully opened database at \(dbURL.path)")
        return db
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
        if sqlite3_prepare_v2(db, createQuery, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE {
                print("Table creation success")
            }
        }
        sqlite3_finalize(createTable)
    }
    
    func createIndexes() {
        let createIndexQuery = """
        CREATE INDEX IF NOT EXISTS idx_exercise ON WorkoutEntry (exercise);
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createIndexQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Index created successfully.")
            }
        }
        sqlite3_finalize(statement)
    }

    // MARK: - ORM CRUD Operations
    
    func insertORM(exercise: String, weight: Int, reps: Int, sets: Int, notes: String) {
        guard let db = ormDB else { return }
        let insert = workoutTable.insert(
            exerciseCol <- exercise,
            weightCol <- weight,
            repsCol <- reps,
            setsCol <- sets,
            notesCol <- notes
        )
        do {
            try db.run(insert)
            print("ORM Insert successful")
        } catch {
            print("ORM Insert failed: \(error)")
        }
    }
    
    func update(workoutId: Int, newExercise: String, newWeight: Int, newReps: Int, newSets: Int, newNotes: String) {
        let query = "UPDATE WorkoutEntry SET exercise = ?, weight = ?, reps = ?, sets = ?, notes = ? WHERE workout_id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (newExercise as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(newWeight))
            sqlite3_bind_int(statement, 3, Int32(newReps))
            sqlite3_bind_int(statement, 4, Int32(newSets))
            sqlite3_bind_text(statement, 5, (newNotes as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(workoutId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Update successful")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func delete(workout: Workout) {
        let query = "DELETE FROM WorkoutEntry WHERE workout_id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(workout.workout_id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete successful")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func fetchAllWorkoutsORM() -> [Workout] {
        guard let db = ormDB else { return [] }
        var workouts: [Workout] = []

        do {
            for row in try db.prepare(workoutTable) {
                let workout = Workout(
                    workout_id: row[workoutId],
                    exercise: row[exerciseCol],
                    weight: row[weightCol],
                    reps: row[repsCol],
                    sets: row[setsCol],
                    notes: row[notesCol]
                )
                workouts.append(workout)
            }
        } catch {
            print("ORM fetch failed: \(error)")
        }

        return workouts
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

    func fetchStatsForExercise(exercise: String) -> (maxWeight: Int, avgReps: Double, avgSets: Double)? {
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
            sqlite3_bind_text(statement, 1, (exercise as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let maxWeight = sqlite3_column_int(statement, 0)
                let avgReps = sqlite3_column_double(statement, 1)
                let avgSets = sqlite3_column_double(statement, 2)
                result = (Int(maxWeight), avgReps, avgSets)
            }
        }
        sqlite3_finalize(statement)
        return result
    }
}
