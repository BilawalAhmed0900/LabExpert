using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Data.SQLite;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LabExpert
{
    internal class DataService
    {
        private readonly SQLiteConnection connection;

        public DataService()
        {
            string dbFolder = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "com.bilawalahmed0900",
                "LabExpert"
            );

            if (!Directory.Exists(dbFolder))
                Directory.CreateDirectory(dbFolder);
            string dbPath = Path.Combine(dbFolder, "data.db");
            string dbConnectionString = $"Data Source={dbPath};Version=3;";
            connection = new SQLiteConnection(dbConnectionString);
            connection.Open();

            EnsureTableExists();
        }

        private void EnsureTableExists()
        {
            string sqlUsers = @"
            CREATE TABLE IF NOT EXISTS Users (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                Username TEXT UNIQUE NOT NULL,
                PasswordHash TEXT NOT NULL,
                Salt TEXT NOT NULL,
                Permissions INTEGER DEFAULT 0
            );";
            using (var cmd = new SQLiteCommand(sqlUsers, connection))
                cmd.ExecuteNonQuery();
        }
    }
}
