using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SQLite;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace LabExpert
{
    public partial class App : Application
    {
        private DataService dataService;

        protected override void OnStartup(StartupEventArgs e)
        {
            dataService = new LabExpert.DataService();
            if (dataService.AtLeastOneUserRegistered)
            {
                Application.Current.Shutdown();
                return;
            }
            else
            {
                Window mainWindow = new Window
                {
                    Title = LabExpert.Constants.Constants.WINDOW_NAME,
                    ResizeMode = ResizeMode.CanMinimize,
                };

                Frame frame = new Frame
                {
                    NavigationUIVisibility = NavigationUIVisibility.Hidden
                };
                mainWindow.Content = frame;

                Page registerUserPage = new LabExpert.Views.RegisterUsers();
                frame.Navigate(registerUserPage);

                mainWindow.Width = registerUserPage.Width;
                mainWindow.Height = registerUserPage.Height;

                mainWindow.Show();
            }
        }
    }
}
