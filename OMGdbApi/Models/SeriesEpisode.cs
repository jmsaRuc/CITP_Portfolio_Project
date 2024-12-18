using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class SeriesEpisode
{
    [Column("episode_id_v")]
    public string? EpisodeId { get; set; }

    [Column("title_v")]
    public string? Title { get; set; }

    [Column("poster_v")]
    public string? Poster { get; set; }

    [Column("plot_v")]
    public string? Plot { get; set; }

    [Column("relese_date_v")]
    public DateTime? ReleaseDate { get; set; }

    [Column("season_number_v")]
    public long SeasonNumber { get; set; }

    [Column("episode_number_v")]
    public long EpisodeNumber { get; set; }

    [Column("average_rating_v")]
    public decimal AverageRating { get; set; }

    [Column("imdb_rating_v")]
    public decimal ImdbRating { get; set; }

    [Column("popularity_v")]
    public long Popularity { get; set; }
}
