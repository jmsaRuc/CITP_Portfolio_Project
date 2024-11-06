
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Controllers;  // Adjust if necessary to match actual controller   
using OMGdbApi.Models;  // Adjust if necessary to match actual models
using test.EpisodesTest;
using Xunit;
using Xunit.Abstractions;


namespace test.EpisodesTest
{
    public class EpisodesApiTest
    {

        readonly EpisodesRequestClass request = new();

        private EpisodesSchema Episode = new EpisodesSchema();

        [Fact]
        public void GetEpisode_ValidId_ReturnsEpisodeName()
    {
        // Arrange
        var episodes = EpisodesRequestClass.GetSampleEpisodes();
        var episodeId = "1";
        var expectedEpisodeName = "Episode 1";

        // Act
        var episode = episodes.FirstOrDefault(e => e.Id == episodeId);

        // Assert
        Assert.NotNull(episode);
        Assert.Equal(expectedEpisodeName, episode!.Title);


    }
    [Fact]
    public void GetEpisode_InvalidId_ReturnsNull()
    {
        // Arrange
        var episodes = EpisodesRequestClass.GetSampleEpisodes();
        var episodeId = "3";

        // Act
        var episode = episodes.FirstOrDefault(e => e.Id == episodeId);

        // Assert
        Assert.Null(episode);
    }
}
}
        
        
        
        
        
        /*
        private readonly ITestOutputHelper _testOutputHelper;

        public EpisodesApiTest(ITestOutputHelper testOutputHelper)
        {
            _testOutputHelper = testOutputHelper;
        }

        readonly EpisodesRequestClass request = new();

        private EpisodesSchema episodes = new EpisodesSchema();


        [Fact]
        public void Test1_GetEpisode_ById_ReturnsEpisode_WhenFound()
        {
            
        }

    }

}
*/