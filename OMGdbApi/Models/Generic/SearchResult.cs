using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Generic;

public class SearchResult
{
    [Column("type_s")]
    public string? Type { get; set; }

    [Column("id_s")]
    public string? Id { get; set; }

    [Column("title_s")]
    public string? Title { get; set; }

    [Column("poster_s")]
    public string? Poster { get; set; }

    [Column("average_rating_s")]
    public decimal AverageRating { get; set; }

    [Column("imdb_rating_s")]
    public decimal ImdbRating { get; set; }

    [Column("popularity_s")]
    public long Popularity { get; set; }

    [Column("highlight_s")]
    public string? Highlight { get; set; }

    [Column("rank_s")]
    public double Rank { get; set; }
}
