using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Watchlist;

[Table("user_series_watchlist")]
public class WatchlistSeries
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("series_id")]
    public string? SeriesId { get; set; }

    [Column("watchlist")]
    public long? Watchlist_order { get; set; }
}
