using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Generic;

namespace OMGdbApi.Controllers
{
    /// <summary>
    /// Controller for handling generic API requests.
    /// </summary>
    [Route("api/")]
    [ApiController]
    public class GenericController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public GenericController(OMGdbContext context)
        {
            _context = context;
        }

        ////////////////////////////////////////////////////////TopWeeklyTitles/////////////////////////////////////////////////////////

        /////////////////// GET: api/topweekly
        ///
        /// <summary>
        /// Retrieves a paginated list of top weekly titles.
        /// </summary>
        /// <param name="pageSize">Number of records per page.
        ///  Default is 10. Maximum is 1000.</param>
        /// <param name="pageNumber">The page number to return.
        ///  Default is 1.</param>
        /// <param name="sortBy">Options are "imdbRating", "averageRating".
        ///  Default is "popularity".</param>
        /// <returns>A paginated list of top weekly titles.</returns>
        /// <response code="200">Returns the list of top weekly titles.</response>
        [HttpGet("topweekly")]
        [ProducesResponseType(typeof(TopWeeklyTitles), 200)]
        [ProducesResponseType(500)]
        public async Task<ActionResult<IEnumerable<TopWeeklyTitles>>> GetTopWeeklyTitles(
            int? pageSize,
            int? pageNumber,
            string? sortBy
        )
        {
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.TopWeeklyTitles.CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            var topWeeklyTitles = from e in _context.TopWeeklyTitles select e;

            switch (sortBy)
            {
                case "imdbRating":
                    topWeeklyTitles = topWeeklyTitles
                        .OrderByDescending(e => e.ImdbRating)
                        .ThenByDescending(e => e.Popularity);
                    ;
                    break;
                case "averageRating":
                    topWeeklyTitles = topWeeklyTitles
                        .OrderByDescending(e => e.AverageRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                default:
                    topWeeklyTitles = topWeeklyTitles.OrderByDescending(e => e.Popularity);
                    break;
            }

            return await topWeeklyTitles
                .AsNoTracking()
                .Skip(((int)pageNumber - 1) * (int)pageSize)
                .Take((int)pageSize)
                .ToListAsync();
        }
    }
}
