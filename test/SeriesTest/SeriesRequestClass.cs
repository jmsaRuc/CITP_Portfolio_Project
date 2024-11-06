using System;
using System.Collections.Generic;
using test.SeriesTest;


namespace test.SeriesTest
{
    public class SeriesRequestClass
    {
        public static List<SeriesSchema> GetSampleSeries()
        {
            return new List<SeriesSchema>
            {
                new SeriesSchema
                {
                    Id = "1",
                    Title = "Series 1",
                    StartYear = "2022",
                    EndYear = "2022",
                    Poster = "https://www.example.com/poster.jpg",
                    Plot = "The first series plot.",
                    ImdbRating = 8.5M,
                    Ordering = 1
                },
                new SeriesSchema
                {
                    Id = "2",
                    Title = "Series 2",
                    StartYear = "2022",
                    EndYear = "2022",
                    Poster = "https://www.example.com/poster.jpg",
                    Plot = "The second series plot.",
                    ImdbRating = 8.7M,
                    Ordering = 2
                }
            };
        }
    }

}