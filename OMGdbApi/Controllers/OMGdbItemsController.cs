using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;

namespace OMGdbApi.Controllers
{
    [Route("api/OMGdbItem")]
    [ApiController]
    public class OMGdbItemsController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public OMGdbItemsController(OMGdbContext context)
        {
            _context = context;
        }

        // GET: api/OMGdbItems
        [HttpGet]
        public async Task<ActionResult<IEnumerable<OMGdbItem>>> GetOMGdbItems()
        {
            return await _context.OMGdbItems.ToListAsync();
        }

        // GET: api/OMGdbItems/5
        [HttpGet("{id}")]
        public async Task<ActionResult<OMGdbItem>> GetOMGdbItem(long id)
        {
            var oMGdbItem = await _context.OMGdbItems.FindAsync(id);

            if (oMGdbItem == null)
            {
                return NotFound();
            }

            return oMGdbItem;
        }

        // PUT: api/OMGdbItems/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutOMGdbItem(long id, OMGdbItem oMGdbItem)
        {
            if (id != oMGdbItem.Id)
            {
                return BadRequest();
            }

            _context.Entry(oMGdbItem).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!OMGdbItemExists(id))
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

        // POST: api/OMGdbItems
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<OMGdbItem>> PostOMGdbItem(OMGdbItem oMGdbItem)
        {
            _context.OMGdbItems.Add(oMGdbItem);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetOMGdbItem), new { id = oMGdbItem.Id }, oMGdbItem);;
        }

        // DELETE: api/OMGdbItems/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteOMGdbItem(long id)
        {
            var oMGdbItem = await _context.OMGdbItems.FindAsync(id);
            if (oMGdbItem == null)
            {
                return NotFound();
            }

            _context.OMGdbItems.Remove(oMGdbItem);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool OMGdbItemExists(long id)
        {
            return _context.OMGdbItems.Any(e => e.Id == id);
        }
    }
}
