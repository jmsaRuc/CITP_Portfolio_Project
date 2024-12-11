using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Ratings;

[Table("user_series_rating")]
public class RatingSeries
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("series_id")]
    public string? SeriesId { get; set; }

    [Column("rating")]
    public short? Rating { get; set; }
}
