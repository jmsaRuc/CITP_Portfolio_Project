using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class Search
{
    public required string UserId { get; set; }

    public required string SearchQuery { get; set; }
}
