using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Controllers;  // Adjust if necessary to match actual controller   
using OMGdbApi.Models;  // Adjust if necessary to match actual models
using test.MovieTest;
using Xunit;
using Xunit.Abstractions;


namespace test.MovieTest
{
    public class MovieApiTest
    {
            
            readonly MovieRequestClass request = new();
    
            private MovieSchema Movie = new MovieSchema();
    
            [Fact]
            public void GetMovie_ValidId_ReturnsMovieName()
        {
            // Arrange
            var movies = MovieRequestClass.GetSampleMovies();
            var movieId = "1";
            var expectedMovieName = "Movie 1";
    
            // Act
            var movie = movies.FirstOrDefault(e => e.Id == movieId);
    
            // Assert
            Assert.NotNull(movie);
            Assert.Equal(expectedMovieName, movie!.Title);
        }
        [Fact]
        public void GetMovie_InvalidId_ReturnsNull()
        {
            // Arrange
            var movies = MovieRequestClass.GetSampleMovies();
            var movieId = "3";
    
            // Act
            var movie = movies.FirstOrDefault(e => e.Id == movieId);
    
            // Assert
            Assert.Null(movie);
        }

    }

}