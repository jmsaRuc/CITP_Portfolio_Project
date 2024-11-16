using System;
using System.ComponentModel.DataAnnotations.Schema;
namespace OMGdbApi.Models.Users.Watchlist;

[Table("user_movie_watchlist")]
public class WatchlistMovie
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("movie_id")]
    public string? MovieId { get; set; }

    [Column("watchlist")]
    public long watchlist_order { get; set; }

}
