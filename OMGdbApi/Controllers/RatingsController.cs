
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Users.Ratings;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user/")]
    [ApiController]
    public class RatingsController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public RatingsController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
        }

        ///////////////////////////////////////////////////////////////////rating/"ALL"///////////////////////////////////////////////////////////////////

        // GET: api/user/{UserId}/ratings
        [HttpGet("{UserId}/ratings")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<RatingALL>>> GetRatings(
            string UserId,
            int? pageSize,
            int? pageNumber
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
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

        // GET: api/user/{UserId}/ratings/episode/{EpisodeId}
        [HttpGet("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<RatingEpisode>> GetRatingEpisode(
            string UserId,
            string EpisodeId
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
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

        // POST: api/user/ratings/episode
        [HttpPost("ratings/episode")]
        [Authorize]
        public async Task<ActionResult<RatingEpisode>> PostRatingEpisode(
            RatingEpisode ratingEpisode
        )
        {
            if (!_validateIDs.ValidateUserId(ratingEpisode.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(ratingEpisode.EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
            }

            if (ratingEpisode.Rating < 1 || ratingEpisode.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingEpisode.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(ratingEpisode.EpisodeId!))
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
                if (RatingEpisodeExists(ratingEpisode.UserId!, ratingEpisode.EpisodeId!))
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

        // PUT: api/user/{UserId}/ratings/episode/{EpisodeId}
        [HttpPut("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<RatingEpisode>> PutRatingEpisode(
            string UserId,
            string EpisodeId,
            RatingEpisode ratingEpisode
        )
        {
            if (
                !_validateIDs.ValidateUserId(UserId)
                || !_validateIDs.ValidateUserId(ratingEpisode.UserId)
            )
            {
                return BadRequest("Invalid UserId");
            }

            if (
                !_validateIDs.ValidateTitleId(EpisodeId)
                || !_validateIDs.ValidateTitleId(ratingEpisode.EpisodeId)
            )
            {
                return BadRequest("Invalid EpisodeId");
            }

            if (ratingEpisode.Rating < 1 || ratingEpisode.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingEpisode.UserId!))
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

        // DELETE: api/user/{UserId}/ratings/episode/{EpisodeId}
        [HttpDelete("{UserId}/ratings/episode/{EpisodeId}")]
        [Authorize]
        public async Task<IActionResult> DeleteRatingEpisode(string UserId, string EpisodeId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
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

        ///////////////////////////////////////////////////////////////////rating/movie///////////////////////////////////////////////////////////////////
        
        // GET: api/user/{UserId}/ratings/movie/{MovieId}
        [HttpGet("{UserId}/ratings/movie/{MovieId}")]
        [Authorize]
        public async Task<ActionResult<RatingMovie>> GetRatingMovie(string UserId, string MovieId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(MovieId))
            {
                return BadRequest($"Movie dose not exist {MovieId}");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingMovie = await _context.RatingMovie.FindAsync(UserId, MovieId);

            if (ratingMovie == null)
            {
                return NotFound($"User has not rated this movie {MovieId}");
            }

            return ratingMovie;
        }

        // POST: api/user/ratings/movie
        [HttpPost("ratings/movie")]
        [Authorize]
        public async Task<ActionResult<RatingMovie>> PostRatingMovie(RatingMovie ratingMovie)
        {
            if (!_validateIDs.ValidateUserId(ratingMovie.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(ratingMovie.MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (ratingMovie.Rating < 1 || ratingMovie.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingMovie.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(ratingMovie.MovieId!))
            {
                return BadRequest("Movie dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != ratingMovie.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.RatingMovie.Add(ratingMovie);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (RatingMovieExists(ratingMovie.UserId!, ratingMovie.MovieId!))
                {
                    return Conflict("User has already rated this movie");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetRatingMovie),
                new { ratingMovie.UserId, ratingMovie.MovieId },
                ratingMovie
            );
        }

        // PUT: api/user/{UserId}/ratings/movie/{MovieId}
        [HttpPut("{UserId}/ratings/movie/{MovieId}")]
        [Authorize]
        public async Task<ActionResult<RatingMovie>> PutRatingMovie(
            string UserId,
            string MovieId,
            RatingMovie ratingMovie
        )
        {
            if (
                !_validateIDs.ValidateUserId(UserId)
                || !_validateIDs.ValidateUserId(ratingMovie.UserId)
            )
            {
                return BadRequest("Invalid UserId");
            }

            if (
                !_validateIDs.ValidateTitleId(MovieId)
                || !_validateIDs.ValidateTitleId(ratingMovie.MovieId)
            )
            {
                return BadRequest("Invalid MovieId");
            }

            if (ratingMovie.Rating < 1 || ratingMovie.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingMovie.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.Entry(ratingMovie).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) when (!RatingMovieExists(UserId, MovieId))
            {
                return NotFound("User has not rated this movie");
            }

            return CreatedAtAction(
                nameof(GetRatingMovie),
                new { ratingMovie.UserId, ratingMovie.MovieId },
                ratingMovie
            );
        }

        // DELETE: api/user/{UserId}/ratings/movie/{MovieId}
        [HttpDelete("{UserId}/ratings/movie/{MovieId}")]
        [Authorize]
        public async Task<IActionResult> DeleteRatingMovie(string UserId, string MovieId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingMovie = await _context.RatingMovie.FindAsync(UserId, MovieId);

            if (ratingMovie == null)
            {
                return NotFound("User has not rated this movie");
            }

            _context.RatingMovie.Remove(ratingMovie);
            await _context.SaveChangesAsync();

            return Ok("Rating deleted");
        }

        ///////////////////////////////////////////////////////////////////rating/series///////////////////////////////////////////////////////////////////

        // GET: api/user/{UserId}/ratings/series/{SeriesId}
        [HttpGet("{UserId}/ratings/series/{SeriesId}")]
        [Authorize]
        public async Task<ActionResult<RatingSeries>> GetRatingSeries(
            string UserId,
            string SeriesId
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingSeries = await _context.RatingSeries.FindAsync(UserId, SeriesId);

            if (ratingSeries == null)
            {
                return NotFound("User has not rated this series");
            }

            return ratingSeries;
        }
        
        // POST: api/user/ratings/series
        [HttpPost("ratings/series")]
        [Authorize]
        public async Task<ActionResult<RatingSeries>> PostRatingSeries(RatingSeries ratingSeries)
        {
            if (!_validateIDs.ValidateUserId(ratingSeries.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(ratingSeries.SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (ratingSeries.Rating < 1 || ratingSeries.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingSeries.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(ratingSeries.SeriesId!))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != ratingSeries.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.RatingSeries.Add(ratingSeries);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (RatingSeriesExists(ratingSeries.UserId!, ratingSeries.SeriesId!))
                {
                    return Conflict("User has already rated this series");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetRatingSeries),
                new { ratingSeries.UserId, ratingSeries.SeriesId },
                ratingSeries
            );
        }

        // PUT: api/user/{UserId}/ratings/series/{SeriesId}
        [HttpPut("{UserId}/ratings/series/{SeriesId}")]
        [Authorize]
        public async Task<ActionResult<RatingSeries>> PutRatingSeries(
            string UserId,
            string SeriesId,
            RatingSeries ratingSeries
        )
        {
            if (
                !_validateIDs.ValidateUserId(UserId)
                || !_validateIDs.ValidateUserId(ratingSeries.UserId)
            )
            {
                return BadRequest("Invalid UserId");
            }

            if (
                !_validateIDs.ValidateTitleId(SeriesId)
                || !_validateIDs.ValidateTitleId(ratingSeries.SeriesId)
            )
            {
                return BadRequest("Invalid SeriesId");
            }

            if (ratingSeries.Rating < 1 || ratingSeries.Rating > 10)
            {
                return BadRequest("Rating must be between 1 and 10");
            }

            if (!UserExists(ratingSeries.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.Entry(ratingSeries).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) when (!RatingSeriesExists(UserId, SeriesId))
            {
                return NotFound("User has not rated this series");
            }

            return CreatedAtAction(
                nameof(GetRatingSeries),
                new { ratingSeries.UserId, ratingSeries.SeriesId },
                ratingSeries
            );
        }

        // DELETE: api/user/{UserId}/ratings/series/{SeriesId}
        [HttpDelete("{UserId}/ratings/series/{SeriesId}")]
        [Authorize]
        public async Task<IActionResult> DeleteRatingSeries(string UserId, string SeriesId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var ratingSeries = await _context.RatingSeries.FindAsync(UserId, SeriesId);

            if (ratingSeries == null)
            {
                return NotFound("User has not rated this series");
            }

            _context.RatingSeries.Remove(ratingSeries);
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
