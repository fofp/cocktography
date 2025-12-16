using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace fofp
{
    public class cpi
    {

        private Dictionary<int, string> widechodes = new Dictionary<int,string>();
        private Dictionary<int, string> thinchodes = new Dictionary<int, string>();
        private Dictionary<string, string> kontolchodes = new Dictionary<string, string>();
        private Dictionary<string, int> reversewide = new Dictionary<string, int>();
        private Dictionary<string, int> reversethin = new Dictionary<string, int>();
        private byte sentinel = 0x0f;

        public enum CockMode
        {
            THIN_CHODE,
            WIDE_CHODE,
            MIXED_CHODE
        }


        public cpi()
        {
            int i = 0;
            string dick = "";
            using (var sr = new StreamReader("rodsetta_stone.txt"))
            {
                while ((dick = sr.ReadLine()) != null)
                {
                    widechodes.Add(i, dick);
                    reversewide.Add(dick, i);
                    ++i;
                }
            }
            i = 0;
            dick = "";
            using (var sr = new StreamReader("cock_bytes.txt"))
            {
                while ((dick = sr.ReadLine()) != null)
                {
                    thinchodes.Add(i, dick);
                    reversethin.Add(dick, i);
                    ++i;
                }

            }
            dick = "";
            using (var sr = new StreamReader("kontol_chodes.txt"))
            {
                while ((dick = sr.ReadLine()) != null)
                {
                    kontolchodes.Add(dick.Split()[0], dick.Split()[1]);
                }
            }
            
        }

        /// <summary>
        /// This converts string data to dicks.
        /// </summary>
        /// <param name="text">The text to be converted</param>
        /// <param name="strokes">The number of strokes to apply</param>
        /// <param name="maxLength">Max lentgth of each line to return</param>
        /// <param name="mode">Thin: 1 byte dicks. Wide: 2 byte dicks. Mixed:a random mix of thin and wide</param>
        /// <param name="variance">Percent change for mixed dicks to be Wide when in Mixed mode</param>
        /// <returns>Returns a string array, each element is a cockblock no longer than maxLength</returns>
        public string[] Enchode(string text, int strokes = 2, int maxLength = 280, CockMode mode = CockMode.MIXED_CHODE, int variance = 50)
        {
            StringBuilder chodes = new StringBuilder();
            List<string> cockblocks = new List<string>();

            string cocks = BytesToChodes(Encoding.UTF8.GetBytes(Stroke(text, strokes)), mode, variance);

            chodes.Append(kontolchodes["START"]);

            foreach (var cock in cocks.Split(' '))
            {
                if (chodes.Length + cock.Length + kontolchodes["STOP"].Length + 2 > maxLength)
                {
                    chodes.Append(String.Format(" {0}", kontolchodes["CONT"]));
                    cockblocks.Add(chodes.ToString());
                    chodes.Clear();
                    chodes.Append(String.Format("{0} {1}", kontolchodes["MARK"], cock));
                }
                else {
                    chodes.Append(String.Format(" {0}", cock));
                }
            }
            chodes.Append(String.Format(" {0}", kontolchodes["STOP"]));
            cockblocks.Add(chodes.ToString());

            return cockblocks.ToArray();         
        }

        /// <summary>
        /// Dechodes a message from dicks to string
        /// </summary>
        /// <param name="dicks">A collection of cockblocks to be dechoded</param>
        /// <returns>An array of strings. The first value is the number of strokes dechoded, while the second is the message.</returns>
        public string[] Dechode(string dicks)
        {
            //chodes.FirstOrDefault(x => x.Value == "one").Key
            var fart = ChodesToBytes(dicks);
            var poop = Encoding.UTF8.GetString(fart);
            try
            {
                return Destroke(poop);
            }
            catch
            {
                return null;
            }
        }

        private string Stroke(string text, int count)
        {
            text = ((char)sentinel + text);

            while (count > 0)
            {
                text = Convert.ToBase64String(Encoding.UTF8.GetBytes(text), Base64FormattingOptions.None);
                --count;
            }
            return text;
        }

        private string[] Destroke(String text)
        {
            int strokes = 0;
            //noinspection ConstantConditions
            while (text[0] != sentinel && text.Length % 4 == 0 && text.Length > 0)
            {
                text = new string(Encoding.UTF8.GetChars(Convert.FromBase64String(text)));
                ++strokes;
            }
            var poop = text.Remove(0, 1);
            return new string[] { strokes.ToString(), poop };
        }

        private string BytesToChodes(byte[] data, CockMode mode, int variance)
        {
            List<String> dicks = new List<string>();

            byte prev = 0;
            bool eatme = false;
            Random rand = new Random();

            if (mode == CockMode.THIN_CHODE)
            {
                foreach (var b in data)
                {
                    dicks.Add(thinchodes[(int)b]);
                }
            }

            if (mode == CockMode.WIDE_CHODE)
            {

                foreach (var b in data)
                {
                    if (!eatme)
                    {
                        eatme = true;
                        prev = b;
                    }
                    else {
                        dicks.Add(widechodes[(int)(prev << 8 | b)]);
                        eatme = false;
                    }
                }
                if (eatme)
                {
                    dicks.Add(thinchodes[(int)prev]);
                }
            }
            if (mode == CockMode.MIXED_CHODE)
            {
                foreach (var b in data)
                {
                    if (rand.Next(1,100) < variance)
                    {
                        if (!eatme)
                        {
                            dicks.Add(thinchodes[(int)b]);
                            eatme = false;
                        }
                        else {
                            dicks.Add(thinchodes[(int)prev]);
                            prev = b;
                            eatme = true;
                        }
                    }
                    else {
                        if (!eatme)
                        {
                            eatme = true;
                            prev = b;
                        }
                        else {
                            dicks.Add(widechodes[(int)(prev << 8 | b)]);
                            eatme = false;
                        }
                    }
                }
                if (eatme)
                {
                    dicks.Add(thinchodes[(int)prev]);
                }
            }
            return String.Join(" ", dicks);
        }

        private byte[] ChodesToBytes(string chodes)
        {
            var result = new MemoryStream();

            byte[] buff = new byte[2];
            int? value;
            foreach (var chode in chodes.Split(' ')) 
            {

                
                if (reversewide.ContainsKey(chode))
                {
                    buff[0] = (byte)(reversewide[chode] >> 8);
                    buff[1] = (byte)(reversewide[chode] & 0xFF);

                    result.Write(buff, 0, 2);
                }
                if (reversethin.ContainsKey(chode))
                {
                    buff[0] = (byte)(reversethin[chode] & 0xFF);
                    result.Write(buff, 0, 1);
                }
            }
            return result.ToArray(); 
        }
    }
}
