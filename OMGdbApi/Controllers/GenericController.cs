using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Generic;
using OMGdbApi.Service;

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

        private readonly ValidateIDs _validateIDs = new();

        public GenericController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
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

        ////////////////////////////////////////////////////////search/////////////////////////////////////////////////////////

        //GET: api/search
        [HttpPut("search")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<SearchResult>>> GetSearch(
            Search search,
            int? pageSize,
            int? pageNumber
        )
        {
            if (string.IsNullOrEmpty(search.UserId) || string.IsNullOrEmpty(search.SearchQuery))
            {
                return BadRequest("User id or search query is missing");
            }

            if (!_validateIDs.ValidateUserId(search.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!UserExists(search.UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!_validateIDs.ValidateSearchQuery(search.SearchQuery))
            {
                return BadRequest("Invalid search query");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != search.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            string searchQuery = search.SearchQuery;
            string UserId = search.UserId;

            if (pageSize == null || pageSize < 1 || pageSize > 100)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }

            var totalRecords = await _context
                .SearchResult.FromSqlInterpolated(
                    $"SELECT * FROM search_all({searchQuery}, {UserId})"
                )
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            return await _context
                .SearchResult.FromSqlInterpolated(
                    $"SELECT * FROM search_all({searchQuery}, {UserId})"
                )
                .AsNoTracking()
                .OrderByDescending(x => x.Rank)
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        private bool UserExists(string id)
        {
            return _context.Users.Any(e => e.Id == id);
        }
    }
}
