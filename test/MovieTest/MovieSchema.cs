using System.ComponentModel.DataAnnotations.Schema;

namespace test.MovieTest;

public class MovieSchema
{
    [Column("movie_id")]
    public string? Id { get; set; }

    [Column("title")]
    public string? Title { get; set; }

    [Column("re_year")]
    public string? ReleaseYear { get; set; }

    [Column("run_time")]
    public string? RunTime { get; set; }

    [Column("poster")]
    public string? Poster { get; set; }

    [Column("plot")]
    public string? Plot { get; set; }

    [Column("release_date")]
    public DateTime? ReleaseDate { get; set; }

    [Column("imdb_rating")]
    public decimal? ImdbRating { get; set; }

    [Column("popularity")]
    public long Popularity { get; set; }

}