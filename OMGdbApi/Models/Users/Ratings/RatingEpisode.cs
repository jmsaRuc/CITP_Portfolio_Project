using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Ratings;

[Table("user_episode_rating")]
public class RatingEpisode
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("episode_id")]
    public string? EpisodeId { get; set; }

    [Column("rating")]
    public short? Rating { get; set; }
}
