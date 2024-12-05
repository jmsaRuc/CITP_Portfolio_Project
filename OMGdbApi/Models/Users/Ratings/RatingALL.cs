using System;

using System.ComponentModel.DataAnnotations.Schema;
namespace OMGdbApi.Models.Users.Ratings;

public class RatingALL
{
    [Column("title_id")]
    public string? Title_id { get; set; }
    [Column("title_type")]
    public string? Title_type { get; set; } 
    [Column("title_of")]
    public string? Title { get; set; }
    [Column("poster_of")]
    public string? Poster { get; set; }
    [Column("average_r")]
    public decimal AverageRating { get; set; }
    [Column("imdb_r")]
    public decimal ImdbRating { get; set; }
    [Column("user_rating")]
    public short UserRating { get; set; }
}
