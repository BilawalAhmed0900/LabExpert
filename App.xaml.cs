using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Data.SQLite;

namespace LabExpert
{
    public partial class App : Application
    {
        private DataService dataService;
        private void MainFunction(object sender, EventArgs e)
        {
            dataService = new LabExpert.DataService();
        }
    }
}
