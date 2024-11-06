using System;
using System.Collections.Generic;
using test.MovieTest;


namespace test.MovieTest
{
    public class MovieRequestClass
    {
        public static List<MovieSchema> GetSampleMovies()
        {
            return new List<MovieSchema>
            {
                new MovieSchema
                {
                    Id = "1",
                    Title = "Movie 1",
                    ReleaseYear = "2022",
                    RunTime = "120 min",
                    Poster = "poster1.jpg",
                    Plot = "The first movie plot.",
                    ReleaseDate = new DateTime(2022, 5, 1),
                    ImdbRating = 8.5M,
                    Ordering = 1
                },
                new MovieSchema
                {
                    Id = "2",
                    Title = "Movie 2",
                    ReleaseYear = "2022",
                    RunTime = "130 min",
                    Poster = "poster2.jpg",
                    Plot = "The second movie plot.",
                    ReleaseDate = new DateTime(2022, 5, 8),
                    ImdbRating = 8.7M,
                    Ordering = 2
                }
            };
        }
    }

}