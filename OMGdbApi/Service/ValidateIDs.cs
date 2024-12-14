using OMGdbApi.Models;

namespace OMGdbApi.Service;

public class ValidateIDs
{
    public GenreAll[]? PossibleGenreNames { get; set; }

    // Validate the different IDs that are used in the database
    /// - User id
    /// - Title id
    /// - Person id
    /// - Genre name

    public bool ValidateUserId(string? UserId)
    {
        if (!GeneralValidate(UserId))
        {
            return false;
        }

        char SplitUserId1 = UserId != null ? UserId[0] : '\0';
        char SplitUserId2 = UserId != null ? UserId[1] : '\0';

        if (SplitUserId1 != 'u' || SplitUserId2 != 'r')
        {
            return false;
        }

        return true;
    }

    public bool ValidateTitleId(string? TitleId)
    {
        if (!GeneralValidate(TitleId))
        {
            return false;
        }

        char SplitTitleId1 = TitleId != null ? TitleId[0] : '\0';
        char SplitTitleId2 = TitleId != null ? TitleId[1] : '\0';

        if (SplitTitleId1 != 't' || SplitTitleId2 != 't')
        {
            return false;
        }

        return true;
    }

    public bool ValidatePersonId(string? PersonId)
    {
        if (!GeneralValidate(PersonId))
        {
            return false;
        }

        char SplitPersonId1 = PersonId != null ? PersonId[0] : '\0';
        char SplitPersonId2 = PersonId != null ? PersonId[1] : '\0';

        if (SplitPersonId1 != 'n' || SplitPersonId2 != 'm')
        {
            return false;
        }

        return true;
    }

    public bool ValidateGenreName(string? GenreName)
    {
        if (PossibleGenreNames == null || PossibleGenreNames.Length == 0)
        {
            throw new Exception("PossibleGenreNames is not set");
        }

        if (
            PossibleGenreNames == null
            || PossibleGenreNames.Length == 0
            || !Array.Exists(PossibleGenreNames, e => e.GenreName == GenreName)
        )
        {
            return false;
        }

        return true;
    }

    // General validation for all IDs
    private static bool GeneralValidate(string? Id)
    {
        if (string.IsNullOrEmpty(Id))
        {
            return false;
        }

        if (string.IsNullOrWhiteSpace(Id))
        {
            return false;
        }

        if (Id == "")
        {
            return false;
        }

        if (Id == null)
        {
            return false;
        }

        if (Id != null && Id.Length > 10)
        {
            return false;
        }

        if (Id != null && Id.Length < 3)
        {
            return false;
        }

        string IdNumber = Id != null ? Id[2..] : string.Empty;

        if (!int.TryParse(IdNumber, out int _))
        {
            return false;
        }

        return true;
    }
}
