using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LabExpert.Models
{
    [Flags]
    public enum UserPermission
    {
        CAN_ADD_PATIENTS = 1 << 0,
        CAN_VISIT_PATIENTS = 1 << 1,
        CAN_MAKE_REPORTS = 1 << 2,
        CAN_ADD_OTHER_USERS = 1 << 3
    }

    public class User
    {
        public int id { get; }
        public string name { get; }
        public UserPermission permission { get; }
        User(int id, string name, UserPermission permission)
        {
            this.id = id;
            this.name = name;
            this.permission = permission;
        }
    }
}
