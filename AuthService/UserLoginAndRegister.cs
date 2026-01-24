using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SQLite;

namespace LabExpert.AuthService
{
    public class UserLoginAndRegister
    {
        private readonly SQLiteConnection connection;

        UserLoginAndRegister(SQLiteConnection connection)
        {
            this.connection = connection ?? throw new ArgumentNullException(nameof(connection));
        }
    }
}
