using System.ComponentModel.DataAnnotations.Schema;

namespace test.EpisodesTest;

public class EpisodesSchema
{
   
        [Column("episode_id")]
        public string? Id { get; set; }

        [Column("title")]
        public string? Title { get; set; }

        [Column("re_year")]
        public string? ReleaseYear { get; set; }

        [Column("run_time")]

        public string? RunTime { get; set; }

        [Column("plot")]

        public string? Plot { get; set; }

        [Column("relese_date")]

        public DateTime? ReleaseDate { get; set; }

        [Column("imdb_rating")]

        public decimal? ImdbRating { get; set; }

        [Column("popularity")]

        public long Popularity { get; set; }

    
}

