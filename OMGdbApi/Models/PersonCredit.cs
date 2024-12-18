using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class PersonCredit
{
    [Column("title_id_v")]
    public string? TitleId { get; set; }

    [Column("title_v")]
    public string? Title { get; set; }

    [Column("title_type_v")]
    public string? TitleType { get; set; }

    [Column("poster_v")]
    public string? Poster { get; set; }

    [Column("character_v")]
    public string? Character { get; set; }

    [Column("imdb_rating_v")]
    public decimal ImdbRating { get; set; }

    [Column("re_year_v")]
    public string? ReleaseYear { get; set; }

    [Column("popularity_v")]
    public long Popularity { get; set; }
}
