using System;
using System.Collections.Generic;
using test.EpisodesTest;


namespace test.EpisodesTest
{
    public class EpisodesRequestClass
    {
   public static List<EpisodesSchema> GetSampleEpisodes()
        {
            return new List<EpisodesSchema>
            {
                new EpisodesSchema
                {
                    Id = "1",
                    Title = "Episode 1",
                    ReleaseYear = "2022",
                    RunTime = "45 min",
                    Plot = "The first episode plot.",
                    ReleaseDate = new DateTime(2022, 5, 1),
                    ImdbRating = 8.5M,
                    Ordering = 1
                },
                new EpisodesSchema
                {
                    Id = "2",
                    Title = "Episode 2",
                    ReleaseYear = "2022",
                    RunTime = "48 min",
                    Plot = "The second episode plot.",
                    ReleaseDate = new DateTime(2022, 5, 8),
                    ImdbRating = 8.7M,
                    Ordering = 2
                }
            };
        }


    }
}


