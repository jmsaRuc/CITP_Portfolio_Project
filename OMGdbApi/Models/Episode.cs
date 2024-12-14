using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Numerics;

namespace OMGdbApi.Models
{
    [Table("episode")]
    public class Episode
    {
        [Column("episode_id")]
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

        [Column("relese_date")]
        public DateTime? ReleaseDate { get; set; }

        [Column("average_rating")]
        public decimal AverageRating { get; set; }

        [Column("imdb_rating")]
        public decimal ImdbRating { get; set; }

        [Column("popularity")]
        public long Popularity { get; set; }
    }
}
