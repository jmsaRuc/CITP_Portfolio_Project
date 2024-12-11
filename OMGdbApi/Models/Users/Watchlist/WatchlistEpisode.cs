using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Watchlist;

[Table("user_episode_watchlist")]
public class WatchlistEpisode
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("episode_id")]
    public string? EpisodeId { get; set; }

    [Column("watchlist")]
    public long? Watchlist_order { get; set; }
}
