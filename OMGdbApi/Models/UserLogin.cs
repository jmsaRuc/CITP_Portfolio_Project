using System;

namespace OMGdbApi.Models;

public class UserLogin
{
    public required string Id { get; set; }
    public required string Token { get; set; }
}
