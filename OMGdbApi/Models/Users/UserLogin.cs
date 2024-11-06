using System;

namespace OMGdbApi.Models.Users;

public class UserLogin
{
    public required string Id { get; set; }
    public required string Token { get; set; }
}
