using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class Genre
{
    [Column("genre_name_of")]
    public string? GenreName { get; set; }

    [Column("episode_amount")]
    public int? EpisodeAmount { get; set; }

    [Column("movie_amount")]
    public int? MovieAmount { get; set; }

    [Column("series_amount")]
    public int? SeriesAmount { get; set; }

    [Column("total_amount")]
    public int? TotalAmount { get; set; }
}
