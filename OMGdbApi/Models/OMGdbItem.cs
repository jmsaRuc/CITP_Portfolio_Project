using System;

namespace OMGdbApi.Models;

public class OMGdbItem
{
    public long Id { get; set; }
    public string? Name { get; set; }
    public bool IsComplete { get; set; }
}
