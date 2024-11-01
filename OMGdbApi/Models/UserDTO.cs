using System;

namespace OMGdbApi.Models;

public class UserDTO
{   
    public string? Id { get; set; }
    public string? Name { get; set; }
    public string? Email { get; set; }
    public DateTime Created_at { get; set; }
}
