using System.Security.Cryptography;
using System.Text;

namespace OMGdbApi.Service;

public class Hashing
{
    protected const int _saltBitSize = 64;
    protected const byte saltBitSize = _saltBitSize / 8;
    protected const int _hashBitSize = 256;
    protected const int hashBitSize = _hashBitSize / 8;

    private HashAlgorithm sha256 = SHA256.Create();
    protected RandomNumberGenerator rng = RandomNumberGenerator.Create();

    public (byte[] hash, string salt) Hash(string password)
    {
        byte[] salt = new byte[saltBitSize];
        rng.GetBytes(salt);
        string saltString = Convert.ToHexString(salt);
        byte[] hash = HashSHA256(password, saltString);
        return (hash, saltString);
    }

    public bool Verify(string loginpassword, byte[] hashedRegisterdPassword, string salt)
    {
        byte[] hashedlogin = HashSHA256(loginpassword, salt);
        if (hashedlogin == hashedRegisterdPassword)
        {
            return true;
        }
        return false;
    }

    private byte[] HashSHA256(string password, string salt)
    {
        byte[] hashInput = Encoding.UTF8.GetBytes(salt + password);
        byte[] hashOutput = sha256.ComputeHash(hashInput);
        return hashOutput;
    }
}
