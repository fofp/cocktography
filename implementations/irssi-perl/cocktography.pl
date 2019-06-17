#########
# Cocktography v1.0 for irsii 
# by the Fraternal Order of the Friends of the Penis
# MIT license shit or whatever, idk, go nuts

# usage:
# /script load /path/to/cocktography.pl
# /enchode message
#      This will create and transmit a cocktographic message to the current window. 
#      It accepts 2 flags:
#      strokes - This controls how spammy the sent messages are with a numerical value
#      mode - This controls the style of dicks transmitted
#             t - Thin - These dicks look the most like ascii dicks in most applications
#             w - Wide - These dicks can transmit 16 bits of data per chode
#             m - Mixed - A mix of thin and wide chodes
#
# Examples:
# /enchode /stroke:5 /mode:w your mother
#     sends  8=wm=D BwuD,~ BmD;;` 8mD``;` 8nD`';, BunD,, 8=D;;~; B=D', 8w==D` 8uD~;,~ 8=uD~, Bw==D' 8nD'`,, BnD,,; 8mD'`,~ B=u=D' 8wmD,' 8uD`,'~ 8nwD'` 8==D~` 8nD,`;` 8wnD`, 8nD;~'~ 8nwD;' 8uD,` 8uD~;,~ Bm=wD, 8=D~~~; Bww==D BnmD' 8uD~,`~ 8=mw=D
# /enchode -s6mm your mother
#     sends  8=wm=D 8mD~~ 8===D~~~~ 8m=D~~~ 8m=D~~ 8====D~~~~ 8====D~~~ 8==D~~~~ 8mD;~;' 8m==D~~~ 8===D~ Bnmw=D 8====D~~ 8nD,,~; 8w==D~ 8===D~~~~ 8uD';~` 8=D`;'' 8===D~ 8m==D~ 8m==D~~~~ 8====D 8==wD 8==D~~ 8mD~~ 8ummD 8m=D~~~ 8=D`,~, Bnwu=D 8w=D 8mD`''` 8=mD 8=D~~~ 8=muD` 8mD``;~ 8=ww=D
#            8wmD 8====D~~ 8wD~~~ 8====D~ 8w==D~ 8wD~ BuwD;, 8==D~~ 8====D~~ 8nw=D' 8m==D~~~~ 8nD,~'~ 8mD~`', 8m==D~~~ 8w==D~~ 8w===D 8==D~~ B=muD' 8w=D 8mD~~ 8w=D~~~ 8m==D~~~~ 8mD~~ 8====D~~~~ Bn=uD` 8nD~',;~ BmD,~' 8=wD 8=w=D~~~ 8=mw=D
#     note this is two lines if text
# /enchode -stroke 1 -mode w your mother
#     sends  8=wm=D 8mD';,, 8uD''' 8nD;~'~ BmwD;; 8uD`,`~ 8m=uD 8=D`~,' 8nD;``` 8=mw=D
# Each of these transmits the same message, but with the options, you can choose how it appears.
#
#
# This script will automatically dechode incoming messages, displaying the number of strokes the message received before transmission.

use strict;
use warnings;
use Cocktography;
use Irssi;
use Irssi::TextUI;
use Encode;
use vars qw($VERSION %IRSSI);

my $cock = Cocktography::new();
my %buffer; 
my $rooster = "\N{U+1f413}";
my $eggplant = "\N{U+1f346}";

$VERSION = "1.0"; 

%IRSSI = (
    authors     => "fidsah" .
                   "jeian" .
                   "tefad",
    contact     => 'github/fofp',
    patchers    => '',
    name        => 'cocktography',
    description => 'Cummunicate in secret, using dicks!',
    license     => 'MIT',
    url         => 'https://github.com/fofp',
    commands    => 'enchode',
);



sub irsii_enchode($$) {

	my ($input, $server, $window) = @_;
	my $strokes;
	my $mode;
	my $text;
	my $color;
	my $glyph;
	
	if ($input =~ /(?:\s+)?(?:[-\\\/]s(?:troke)?[\s:]?(\d+)\s?|[-\\\/]?m(?:ode)?[\s:]?([twm])\s)*(.*)/){
		$strokes = $1;
		$mode = $2;
		$text = $3;
	}
	if (not defined $strokes) {
		$strokes = 2;
	}
	if (not defined $mode) {
		$mode = 't'; 
	}
		
	
	my %modes = ('t' => 1, 'w' => 2, 'm' =>3);
	my $fatone = Cocktography->enchode_string($text,$strokes,$modes{$mode},280);
    
	
	my @dicks = split("\n",$fatone);
	if ($strokes > 0) {
			$color = 4; 
			$glyph = $eggplant;
    } else {
			$color = 3;
			$glyph = $rooster; 
	} 
	foreach my $dick (@dicks){
	
		$window->command("MSG " . $window->{name}. " " . $dick);
	}
	
	
	$server->print( $window->{name}, '<' . $color . '' . $strokes . $glyph. $server->{nick} . '> ' . $text, MSGLEVEL_MSGS);
	Irssi::signal_stop();
}
sub irsii_dechode($$) {
	my ($dicks) = @_;
	my $fatone = Cocktography->dechode_string($dicks);
	print $fatone;
	
}

sub event_privmsg {
	my ($server, $data, $nick, $address) = @_;
	my ($target, $text) = split(/ :/, $data, 2);
	my $key = $nick . $target;
	my @boner = Cocktography->find_cockblocks($text);

	if (not defined  $boner[0][0]) {
		return;
	}
    my @message;
	my $color;
	my $glyph;
    #("SINGLETON" => 1, "INITIAL" => 2, "INTERMEDIATE" => 3, "FINAL" => 4);
	if ($boner[0][0]{"TYPE"} == 1) {
		@message = Cocktography->dechode_string($text);
		if ($message[1] > 0) {
			$color = 4; 
			$glyph = $eggplant;
		} else {
			$color = 0;
			$glyph = $rooster;
		} 
		$server->print($target, '<' . $color . '' . $message[1] . $glyph. $nick . '> ' . $message[0], MSGLEVEL_MSGS);
		Irssi::signal_stop();
	}
	
	if ($boner[0][0]{"TYPE"} == 2) {
	    $buffer{$key} = $text;
		Irssi::signal_stop();
	}
	
	if ($boner[0][0]{"TYPE"} == 3) {
	    $buffer{$key} = $buffer{$key} . ' ' . $text;
		Irssi::signal_stop();
	}
	
	if ($boner[0][0]{"TYPE"} == 4) {

	    $buffer{$key} = $buffer{$key} . ' ' . $text;
		@message = Cocktography->dechode_string($buffer{$key});
				
		if ($message[1] > 0) {
			$color = 4; 
			$glyph = $eggplant;
		} else {
			$color = 3;
			$glyph = $rooster; 
		} 
		
		$server->print($target, '<' . $color . '' . $message[1] . $glyph . $nick . '> ' . $message[0] , MSGLEVEL_MSGS);
		delete $buffer{$key};
		Irssi::signal_stop();
		
	}
	
}

Irssi::command_bind('enchode'      => 'irsii_enchode');
Irssi::command_bind('dechode'      => 'irsii_dechode');
Irssi::signal_add("event privmsg", "event_privmsg");
