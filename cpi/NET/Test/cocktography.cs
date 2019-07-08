using System;
using Cocktography;
using System.Windows.Forms;
using fofp;

namespace Cocktography
{
    public partial class cocktography : Form
    {

        private cpi.CockMode _chodemode = cpi.CockMode.MIXED_CHODE;
        private int _strokes = 2;
        private int _variance = 50;
        cpi cpi = new cpi();
        public cocktography()
        {
            
            InitializeComponent();
            comboBox1.SelectedItem = "Mixed";
        }

        private void btnEnchode_Click(object sender, EventArgs e)
        {
            string[] dongs = cpi.Enchode(Input.Text, _strokes, mode: _chodemode);
            Output.Clear();
            Output.Text = string.Join(Environment.NewLine, dongs);
        }

        private void btnDechode_Click(object sender, EventArgs e)
        {
            var fart = Input.Text.Replace(Environment.NewLine, " ");

            var butt = cpi.Dechode(fart);
            if (butt != null)
            {
                label1.Text = butt[0];
                Output.Text = butt[1];
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch(comboBox1.SelectedItem.ToString())
            {
                case "Wide":
                    textBox1.Enabled = false;
                    _chodemode = cpi.CockMode.WIDE_CHODE;
                    break;
                case "Thin":
                    textBox1.Enabled = false;
                    _chodemode = cpi.CockMode.THIN_CHODE;
                    break;
                case "Mixed":
                    textBox1.Enabled = true;
                    _chodemode = cpi.CockMode.MIXED_CHODE;
                    break;
            }
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            _strokes = trackBar1.Value;
            label5.Text = trackBar1.Value.ToString();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            if (System.Text.RegularExpressions.Regex.IsMatch(textBox1.Text, "[^0-9]"))
            {
                MessageBox.Show("Please enter only numbers.");
                textBox1.Text = "50";
            }
            _variance = Convert.ToInt32(textBox1.Text);
        }

        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.Handled = !char.IsDigit(e.KeyChar) && !char.IsControl(e.KeyChar);
        }
    }
}
