using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Ratings;

[Table("user_movie_rating")]
public class RatingMovie
{
    [Column("user_id")]
    public string? UserId { get; set; }

    [Column("movie_id")]
    public string? MovieId { get; set; }

    [Column("rating")]
    public short? Rating { get; set; }

}
