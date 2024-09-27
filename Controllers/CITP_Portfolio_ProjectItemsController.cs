using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CITP_Portfolio_Project.Models;

namespace CITP_Portfolio_Project.Controllers
{
    [Route("api/CITP_Portfolio_ProjectItems")]
    [ApiController]
    public class CITP_Portfolio_ProjectItemsController : ControllerBase
    {
        private readonly CITP_Portfolio_ProjectContext _context;

        public CITP_Portfolio_ProjectItemsController(CITP_Portfolio_ProjectContext context)
        {
            _context = context;
        }

        // GET: api/CITP_Portfolio_ProjectItems
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CITP_Portfolio_ProjectItem>>> GetCITP_Portfolio_ProjectItems()
        {
            return await _context.CITP_Portfolio_ProjectItems.ToListAsync();
        }

        // GET: api/CITP_Portfolio_ProjectItems/5
        [HttpGet("{id}")]
        public async Task<ActionResult<CITP_Portfolio_ProjectItem>> GetCITP_Portfolio_ProjectItem(long id)
        {
            var cITP_Portfolio_ProjectItem = await _context.CITP_Portfolio_ProjectItems.FindAsync(id);

            if (cITP_Portfolio_ProjectItem == null)
            {
                return NotFound();
            }

            return cITP_Portfolio_ProjectItem;
        }

        // PUT: api/CITP_Portfolio_ProjectItems/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutCITP_Portfolio_ProjectItem(long id, CITP_Portfolio_ProjectItem cITP_Portfolio_ProjectItem)
        {
            if (id != cITP_Portfolio_ProjectItem.Id)
            {
                return BadRequest();
            }

            _context.Entry(cITP_Portfolio_ProjectItem).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CITP_Portfolio_ProjectItemExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/CITP_Portfolio_ProjectItems
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<CITP_Portfolio_ProjectItem>> PostCITP_Portfolio_ProjectItem(CITP_Portfolio_ProjectItem cITP_Portfolio_ProjectItem)
        {
            _context.CITP_Portfolio_ProjectItems.Add(cITP_Portfolio_ProjectItem);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCITP_Portfolio_ProjectItem), new { id = cITP_Portfolio_ProjectItem.Id }, cITP_Portfolio_ProjectItem);
        }

        // DELETE: api/CITP_Portfolio_ProjectItems/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCITP_Portfolio_ProjectItem(long id)
        {
            var cITP_Portfolio_ProjectItem = await _context.CITP_Portfolio_ProjectItems.FindAsync(id);
            if (cITP_Portfolio_ProjectItem == null)
            {
                return NotFound();
            }

            _context.CITP_Portfolio_ProjectItems.Remove(cITP_Portfolio_ProjectItem);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CITP_Portfolio_ProjectItemExists(long id)
        {
            return _context.CITP_Portfolio_ProjectItems.Any(e => e.Id == id);
        }
    }
}
