import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";

// Define model classes if not already done (e.g., in models/ directory)
// For simplicity, we might use Maps directly for now, but models are better for larger apps.

class DatabaseHelper {
  static const _databaseName = "FitApp.db";
  static const _databaseVersion = 1;

  // Table names
  static const tableUserSettings = "UserSettings";
  static const tableWorkoutLog = "WorkoutLog";
  // static const tableDailyProgressSummary = "DailyProgressSummary"; // May derive this or implement later

  // UserSettings columns
  static const columnUserId = "userId";
  static const columnName = "name";
  static const columnAge = "age";
  static const columnWeightKg = "weightKg";
  static const columnHeightCm = "heightCm";
  // Add other UserSettings columns as per design...
  static const columnOnboardingComplete = "onboardingComplete";

  // WorkoutLog columns
  static const columnLogId = "logId";
  // userId is a foreign key to UserSettings
  static const columnActivityName = "activityName";
  static const columnDateCompleted = "dateCompleted"; // TEXT as YYYY-MM-DD
  static const columnTimeCompleted = "timeCompleted"; // TEXT as HH:MM
  static const columnDurationMinutes = "durationMinutes";
  static const columnCaloriesBurned = "caloriesBurned";
  static const columnSteps = "steps";
  static const columnNotes = "notes";

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create it if it doesn_t exist.
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database tables.
  Future _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE $tableUserSettings (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT,
        $columnAge INTEGER,
        $columnWeightKg REAL,
        $columnHeightCm REAL,
        $columnOnboardingComplete INTEGER NOT NULL DEFAULT 0
      )
      """);

    await db.execute("""
      CREATE TABLE $tableWorkoutLog (
        $columnLogId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserId INTEGER NOT NULL,
        $columnActivityName TEXT NOT NULL,
        $columnDateCompleted TEXT NOT NULL,
        $columnTimeCompleted TEXT,
        $columnDurationMinutes INTEGER NOT NULL,
        $columnCaloriesBurned INTEGER,
        $columnSteps INTEGER,
        $columnNotes TEXT,
        FOREIGN KEY ($columnUserId) REFERENCES $tableUserSettings ($columnUserId) ON DELETE CASCADE
      )
      """);
    // Potentially create DailyProgressSummary table here if not deriving it
  }

  // Helper methods

  // Insert a row into the database.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Query all rows from a table.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Query rows based on a WHERE clause.
  Future<List<Map<String, dynamic>>> queryRows(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    Database db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // Update a row in the database.
  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String columnIdName,
    int id,
  ) async {
    Database db = await instance.database;
    return await db.update(
      table,
      row,
      where: "$columnIdName = ?",
      whereArgs: [id],
    );
  }

  // Delete a row from the database.
  Future<int> delete(String table, String columnIdName, int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: "$columnIdName = ?", whereArgs: [id]);
  }

  // Example: Get workout logs for a specific date
  Future<List<Map<String, dynamic>>> getWorkoutLogsForDate(
    String dateYYYYMMDD,
  ) async {
    Database db = await instance.database;
    return await db.query(
      tableWorkoutLog,
      where: "$columnDateCompleted = ?",
      whereArgs: [dateYYYYMMDD],
      orderBy: "$columnLogId DESC", // Or by timeCompleted
    );
  }

  // Example: Insert a workout log
  Future<int> insertWorkoutLog(Map<String, dynamic> logData) async {
    // Assuming logData contains userId, activityName, dateCompleted, durationMinutes, etc.
    return await insert(tableWorkoutLog, logData);
  }

  // Get recent workout logs for the charts tab
  Future<List<Map<String, dynamic>>> getRecentWorkoutLogs({
    int limit = 5,
  }) async {
    Database db = await instance.database;
    return await db.query(
      tableWorkoutLog,
      orderBy: "$columnDateCompleted DESC, $columnLogId DESC",
      limit: limit,
    );
  }

  // Get aggregated monthly data for charts (e.g., total calories per month)
  Future<List<Map<String, dynamic>>> getMonthlyAggregatedDataForCharts() async {
    Database db = await instance.database;
    // This query sums calories per month. SQLite date functions are used.
    // strftime("%Y-%m", dateCompleted) groups by year and month.
    // We take the last 4 months of data.
    return await db.rawQuery("""
      SELECT 
        strftime('%Y-%m', $columnDateCompleted) as month,
        SUM($columnCaloriesBurned) as totalCalories
      FROM $tableWorkoutLog
      WHERE $columnDateCompleted >= date('now', '-4 months')
      GROUP BY month
      ORDER BY month ASC
      LIMIT 4;
      """);
  }

  // Add more specific methods for UserSettings, etc., as needed.
}
