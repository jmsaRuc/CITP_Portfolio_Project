using System;

namespace OMGdbApi.Models.Users;

public class UserCreate
{
    public string? Name { get; set; }
    public string? Email { get; set; }
    public string? Password { get; set; }

}
