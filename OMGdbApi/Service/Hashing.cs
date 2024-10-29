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

    public (byte[] hash, byte[] salt) Hash(string password)
    {
        byte[] salt = new byte[saltBitSize];
        rng.GetBytes(salt);
        byte[] saltString = salt;
        byte[] hash = HashSHA256(password, saltString);
        return (hash, saltString);
    }

    public bool Verify(string loginPassword, byte[] hashedRegisterdPassword, byte[] salt)
    {
        byte[] hashedLogin = HashSHA256(loginPassword, salt);
        if (hashedLogin == hashedRegisterdPassword)
        {
            return true;
        }
        return false;
    }

    private byte[] HashSHA256(string password, byte[] salt)
    {
        byte[] hashInput = Encoding.UTF8.GetBytes(salt + password);
        byte[] hashOutput = sha256.ComputeHash(hashInput);
        return hashOutput;
    }
}
