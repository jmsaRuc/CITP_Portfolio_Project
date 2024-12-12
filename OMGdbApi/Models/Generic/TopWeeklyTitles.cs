using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Generic;

#pragma warning disable CS1591

[Table("top_this_week")]
public class TopWeeklyTitles
{
    [Column("type_id_v")]
    public string? TitleId { get; set; }

    [Column("title_type_v")]
    public string? TitleType { get; set; }

    [Column("title")]
    public string? Title { get; set; }

    [Column("poster")]
    public string? Poster { get; set; }

    [Column("average_rating")]
    public decimal AverageRating { get; set; }

    [Column("imdb_rating")]
    public decimal ImdbRating { get; set; }

    [Column("popularity")]
    public long Popularity { get; set; }

    [Column("pop_created_at")]
    public DateTime DailyTimeStampFromRecentV { get; set; }
}

#pragma warning restore CS1591
