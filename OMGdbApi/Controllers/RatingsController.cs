using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using OMGdbApi.Models;
using OMGdbApi.Models.Users;
using OMGdbApi.Models.Users.Ratings;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user/")]
    [ApiController]
    public class RatingsController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public RatingsController(OMGdbContext context)
        {
            _context = context;
        }

        [HttpGet("{UserId}/ratings")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<RatingALL>>> GetRatings(
            string UserId,
            int? pageSize,
            int? pageNumber
        )
        {
            if (UserId == null)
            {
                return BadRequest("UserId is null");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }
            var totalRecords = await _context
                .RatingALL.FromSqlInterpolated($"SELECT * FROM get_user_rating({UserId})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }

            return await _context
                .RatingALL.FromSqlInterpolated($"SELECT * FROM get_user_rating({UserId})")
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        ///////////////////////////////////////////////////////////////////rating/episode///////////////////////////////////////////////////////////////////

        [HttpGet("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<RatingEpisode>> GetRatingEpisode(
            string UserId,
            string EpisodeId
        )
        {
            if (UserId == null || EpisodeId == null)
            {
                return BadRequest("UserId or EpisodeId is null");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingEpisode = await _context.RatingEpisode.FindAsync(UserId, EpisodeId);

            if (ratingEpisode == null)
            {
                return NotFound("User has not rated this episode");
            }

            return ratingEpisode;
        }

        [HttpPost("ratings/episode")]
        [Authorize]
        public async Task<ActionResult<RatingEpisode>> PostRatingEpisode(
            RatingEpisode ratingEpisode
        )
        {
            if (
                string.IsNullOrEmpty(ratingEpisode.UserId)
                || string.IsNullOrEmpty(ratingEpisode.EpisodeId)
                || ratingEpisode.Rating == null
            )
            {
                return BadRequest("UserId, EpisodeId or rating is null or empty");
            }

            if (ratingEpisode.Rating < 1 || ratingEpisode.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingEpisode.UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(ratingEpisode.EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != ratingEpisode.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.RatingEpisode.Add(ratingEpisode);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (RatingEpisodeExists(ratingEpisode.UserId, ratingEpisode.EpisodeId))
                {
                    return Conflict("User has already rated this episode");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetRatingEpisode),
                new { ratingEpisode.UserId, ratingEpisode.EpisodeId },
                ratingEpisode
            );
        }

        [HttpPut("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<IActionResult> PutRatingEpisode(
            string UserId,
            string EpisodeId,
            RatingEpisode ratingEpisode
        )
        {
            if (
                string.IsNullOrEmpty(ratingEpisode.UserId)
                || string.IsNullOrEmpty(ratingEpisode.EpisodeId)
                || ratingEpisode.Rating == null
            )
            {
                return BadRequest("UserId, EpisodeId or rating is null or empty");
            }

            if (ratingEpisode.Rating < 1 || ratingEpisode.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingEpisode.UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.Entry(ratingEpisode).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) when (!RatingEpisodeExists(UserId, EpisodeId))
            {
                return NotFound("User has not rated this episode");
            }

            return CreatedAtAction(
                nameof(GetRatingEpisode),
                new { ratingEpisode.UserId, ratingEpisode.EpisodeId },
                ratingEpisode
            );
        }

        [HttpDelete("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<IActionResult> DeleteRatingEpisode(string UserId, string EpisodeId)
        {
            if (string.IsNullOrEmpty(UserId) || string.IsNullOrEmpty(EpisodeId))
            {
                return BadRequest("UserId or EpisodeId is null");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingEpisode = await _context.RatingEpisode.FindAsync(UserId, EpisodeId);

            if (ratingEpisode == null)
            {
                return NotFound("User has not rated this episode");
            }

            _context.RatingEpisode.Remove(ratingEpisode);
            await _context.SaveChangesAsync();

            return Ok("Rating deleted");
        }

        private bool UserExists(string UserId)
        {
            return _context.Users.Any(e => e.Id == UserId);
        }

        private bool RatingEpisodeExists(string UserId, string EpisodeId)
        {
            return _context.RatingEpisode.Any(e => e.UserId == UserId && e.EpisodeId == EpisodeId);
        }

        private bool EpisodeExists(string EpisodeId)
        {
            return _context.Episodes.Any(e => e.Id == EpisodeId);
        }

        private bool RatingMovieExists(string UserId, string MovieId)
        {
            return _context.RatingMovie.Any(e => e.UserId == UserId && e.MovieId == MovieId);
        }

        private bool MovieExists(string MovieId)
        {
            return _context.Movie.Any(e => e.Id == MovieId);
        }

        private bool RatingSeriesExists(string UserId, string SeriesId)
        {
            return _context.RatingSeries.Any(e => e.UserId == UserId && e.SeriesId == SeriesId);
        }

        private bool SeriesExists(string SeriesId)
        {
            return _context.Series.Any(e => e.Id == SeriesId);
        }
    }
}
