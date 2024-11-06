using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Controllers;  // Adjust if necessary to match actual controller   
using OMGdbApi.Models;  // Adjust if necessary to match actual models
using test.SeriesTest;
using Xunit;
using Xunit.Abstractions;


namespace test.SeriesTest
{
    public class SeriesApiTest
    {

        readonly SeriesRequestClass request = new();

        private SeriesSchema Series = new SeriesSchema();

        [Fact]
        public void GetSeries_ValidId_ReturnsSeriesName()
        {
            // Arrange
            var series = SeriesRequestClass.GetSampleSeries();
            var seriesId = "1";
            var expectedSeriesName = "Series 1";

            // Act
            var serie = series.FirstOrDefault(e => e.Id == seriesId);

            // Assert
            Assert.NotNull(serie);
            Assert.Equal(expectedSeriesName, serie!.Title);
        }
        [Fact]
        public void GetSeries_InvalidId_ReturnsNull()
        {
            // Arrange
            var series = SeriesRequestClass.GetSampleSeries();
            var seriesId = "3";

            // Act
            var serie = series.FirstOrDefault(e => e.Id == seriesId);

            // Assert
            Assert.Null(serie);
        }
    }
}