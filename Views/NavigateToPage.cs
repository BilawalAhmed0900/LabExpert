using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace LabExpert.Views
{
    public class NavigateToPage
    {
        public void NavigateToPageResizing(Page page, Page newPage)
        {
            if (page == null || newPage == null)
            {
                throw new NoNullAllowedException("Pages must exist");
            }

            if ((page.Parent is Window window) && (page.Parent is Frame frame))
            {
                window.Width = newPage.Width;
                window.Height = newPage.Height;
                frame.Navigate(newPage);
            }
            else
            {
                throw new NoNullAllowedException("Wrong page object");
            }
        }
    }
}
