using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Numerics;


namespace OMGdbApi.Models
{
    [Table("series")]
    public class Series
    {
        [Column("series_id")]
        public string? Id { get; set; }

        [Column("title")]
        public string? Title { get; set; }

        [Column("start_year")]
        public string? StartYear { get; set; }

        [Column("end_year")]
        public string? EndYear { get; set; }

        [Column("poster")]
        public string? Poster { get; set; }

        [Column("plot")]

        public string? Plot { get; set; }

        [Column("imdb_rating")]

        public decimal? ImdbRating { get; set; }

        [Column("popularity")]

       public long? Popularity { get; set; }
    }
}
