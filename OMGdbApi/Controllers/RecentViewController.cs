using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Users.Recent_View;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user/")]
    [ApiController]
    public class RecentViewController : ControllerBase
    {
        private readonly OMGdbContext _context;
        private readonly ValidateIDs _validateIDs = new();

        public RecentViewController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
        }

        //////////////////////////////////////////////////////////////////////////recentview/////////////////////////////////////////////////////////////////////////

        // GET: api/user/{UserId}/recentview/all
        [HttpGet("{UserId}/recentview")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<RecentViewAll>>> GetRecentViewAll(
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
                .RecentViewAll.FromSqlInterpolated($"SELECT * FROM get_user_recent_view({UserId})")
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
                .RecentViewAll.FromSqlInterpolated($"SELECT * FROM get_user_recent_view({UserId})")
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        //////////////////////////////////////////////////////////////////////////recentview/{TypeId}/////////////////////////////////////////////////////////////////////////

        // GET: api/user/{UserId}/recentview/{TypeId}
        [HttpGet("{UserId}/recentview/{TypeId}")]
        [Authorize]
        public async Task<ActionResult<RecentView>> GetRecentView(string UserId, string TypeId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(TypeId) && !_validateIDs.ValidatePersonId(TypeId))
            {
                return BadRequest("Invalid TypeId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!typeExists(TypeId))
            {
                return BadRequest("There is no type entity with this id");
            }
            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var recentView = await _context.RecentView.FindAsync(UserId, TypeId);

            if (recentView == null)
            {
                return NotFound("User has not viewed this entity");
            }

            return recentView;
        }

        // POST: api/user/{UserId}/recentview/{TypeId}
        [HttpPost("recentview")]
        [Authorize]
        public async Task<ActionResult<RecentView>> PostRecentView(RecentView recentView)
        {
            if (!_validateIDs.ValidateUserId(recentView.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (
                !_validateIDs.ValidateTitleId(recentView.TypeId)
                && !_validateIDs.ValidatePersonId(recentView.TypeId)
            )
            {
                return BadRequest("Invalid TypeId");
            }

            if (!UserExists(recentView.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!typeExists(recentView.TypeId!))
            {
                return BadRequest("There is no type entity with this id");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != recentView.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            if (RecentViewExists(recentView.UserId!, recentView.TypeId!))
            {
                await DeleteRecentView(recentView.UserId!, recentView.TypeId!);
            }

            _context.RecentView.Add(recentView);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (RecentViewExists(recentView.UserId!, recentView.TypeId!))
                {
                    throw;
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetRecentView),
                new { recentView.UserId, recentView.TypeId },
                recentView
            );
        }

        // DELETE: api/user/{UserId}/recentview/{TypeId}
        [HttpDelete("{UserId}/recentview/{TypeId}")]
        [Authorize]
        public async Task<IActionResult> DeleteRecentView(string UserId, string TypeId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(TypeId) && !_validateIDs.ValidatePersonId(TypeId))
            {
                return BadRequest("Invalid TypeId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!typeExists(TypeId))
            {
                return BadRequest("There is no type entity with this id");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
            }

            var recentView = await _context.RecentView.FindAsync(UserId, TypeId);
            if (recentView == null)
            {
                return NotFound("User has not viewed this entity");
            }

            _context.RecentView.Remove(recentView);
            await _context.SaveChangesAsync();

            return Ok("Entity removed from recent view");
        }

        private bool UserExists(string UserId)
        {
            return _context.Users.Any(e => e.Id == UserId);
        }

        private bool typeExists(string TypeId)
        {
            return _context.Episode.Any(e => e.Id == TypeId)
                || _context.Movie.Any(e => e.Id == TypeId)
                || _context.Series.Any(e => e.Id == TypeId)
                || _context.Person.Any(e => e.Id == TypeId);
        }

        private bool RecentViewExists(string UserId, string TypeId)
        {
            return _context.RecentView.Any(e => e.UserId == UserId && e.TypeId == TypeId);
        }
    }
}
