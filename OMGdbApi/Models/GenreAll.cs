using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class GenreAll
{
    [Column("genre_name_of")]
    public string? GenreName { get; set; }
}
