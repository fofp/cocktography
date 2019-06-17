package Cocktography;
# Cocktography Perl implementation by jeian.
# I have a B.S. in Computer Information Science, and an M.S. in Information Assurance, and this is what I'm doing with them.

use strict;

use Carp;
use MIME::Base64;
use Text::Wrap;
use Encode;
use List::Util qw(min max);

my %CYPHALLIC_METHOD = ("THIN" => 1, "WIDE" => 2, "MIXED" => 3);
my %COCKBLOCK_TYPE = ("SINGLETON" => 1, "INITIAL" => 2, "INTERMEDIATE" => 3, "FINAL" => 4);
my %COCKBLOCK_TYPE_REVERSE = (1 => "SINGLETON", 2 => "INITIAL", 3 => "INTERMEDIATE", 4 => "FINAL");

my $SEPARATOR = " ";
my $ESCAPE_SENTINEL = chr 0x0F;
my $COCKBLOCK_PADDING;

my %KONTOL_CHODES;

my %thinchodelist;
my %widechodelist;

my @thinchodes;
my @widechodes;

sub new {
		my $class = shift;
		
		my $self = {};
		
		my($parameters) = @_;
		
		my $kontolfilename = exists $parameters->{"kontolfile"} ? $parameters->{"kontolfile"} : "kontol_chodes.txt";
		my $thinfilename = exists $parameters->{"thinfile"} ? $parameters->{"thinfile"} : "cock_bytes.txt";
		my $widefilename = exists $parameters->{"widefile"} ? $parameters->{"widefile"} : "rodsetta_stone.txt";
		
		# Load kontol chodes
		open(my $kontolgrip, "<", $kontolfilename) or croak "Couldn't open kontol chode file $kontolfilename!";
		while(<$kontolgrip>) {
			chomp;
			my ($chode, $kontol) = split(/ /);
			$KONTOL_CHODES{$chode} = $kontol;
			carp "Unrecognized kontol chode $chode found in $kontolfilename!" if($chode ne "START" && $chode ne "STOP" && $chode ne "CONT" && $chode ne "MARK");
		}
		close($kontolgrip);
		croak "Kontol chode START was not found in $kontolfilename!" if(!exists $KONTOL_CHODES{"START"});
		croak "Kontol chode STOP was not found in $kontolfilename!" if(!exists $KONTOL_CHODES{"STOP"});
		croak "Kontol chode CONT was not found in $kontolfilename!" if(!exists $KONTOL_CHODES{"CONT"});
		croak "Kontol chode MARK was not found in $kontolfilename!" if(!exists $KONTOL_CHODES{"MARK"});
		
		$KONTOL_CHODES{"[BEGIN]"} = [$KONTOL_CHODES{'START'}, $KONTOL_CHODES{'MARK'}];
		$KONTOL_CHODES{"[END]"} = [$KONTOL_CHODES{'CONT'}, $KONTOL_CHODES{'STOP'}];
		$COCKBLOCK_PADDING = max(map(length, @{$KONTOL_CHODES{'[BEGIN]'}})) + max(map(length, @{$KONTOL_CHODES{'[END]'}}));
		
		# Load thin-chodes
		open(my $thingrip, "<", $thinfilename) or croak "Couldn't open thin-chode file $thinfilename!";
		while(<$thingrip>) {
			chomp;
			$thinchodelist{$_} = $#thinchodes + 1;
			push @thinchodes, $_;
		}
		close($thingrip);
		
		# Load wide-chodes
		open(my $widegrip, "<", $widefilename) or croak "Couldn't open wide-chode file $widefilename!";
		while(<$widegrip>) {
			chomp;
			$widechodelist{$_} = $#widechodes + 1;
			push @widechodes, $_;
		}
		close($widegrip);
		
		bless $self, $class;
		
}

sub enchode_string($$$$$) {
	# Take plaintext as a string and return a string with the enchoded text.
	# Parameters:
	# [1] - Input text (as string)
	# [2] - Number of strokes (base64 rounds)
	# [3] - Mode (thin/ASCII, wide/Unicode, mixed)
	# [4] - Cockblock size (maximum number of characters in a cockblock before it must be split)
	
	my ($self, $input, $strokes, $mode, $cockblock_size) = @_;
		
	return $self->make_cockchain(
		$self->cyphallicize(
			$self->stroke($input, $strokes),
			$mode),
		$cockblock_size
	);
}

sub dechode_string($$) {
	# Take enchoded text as a string and return a string with the dechoded text.
	# Parameters:
	# [1] - Input text (as string)

	my($self, $input) = @_;
	
	my $dechoded;
	my $prev_type = -1;
	my $condom;
	my $strokes;

	my $cockblocks = $self->find_cockblocks($input);
		
	foreach my $cockblock (@{$cockblocks}) {
		my $cyphallic = $self->decyphallicize($cockblock->{'TEXT'});
		
		if ($cockblock->{'TYPE'} == $COCKBLOCK_TYPE{'SINGLETON'} && ($prev_type != $COCKBLOCK_TYPE{'INITIAL'} && $prev_type != $COCKBLOCK_TYPE{'INTERMEDIATE'})) {
			my ($destroked, $strokecount) = $self->destroke($cyphallic);
			$dechoded .= $destroked;
			$strokes += $strokecount;
		} elsif ($cockblock->{'TYPE'} == $COCKBLOCK_TYPE{'INITIAL'} && ($prev_type != $COCKBLOCK_TYPE{'INITIAL'} && $prev_type != $COCKBLOCK_TYPE{'INTERMEDIATE'})) {
			$condom = $cyphallic;
		} elsif ($cockblock->{'TYPE'} == $COCKBLOCK_TYPE{'INTERMEDIATE'} && ($prev_type == $COCKBLOCK_TYPE{'INITIAL'} || $prev_type == $COCKBLOCK_TYPE{'INTERMEDIATE'})) {
			$condom .= $cyphallic;
		} elsif ($cockblock->{'TYPE'} == $COCKBLOCK_TYPE{'FINAL'} && ($prev_type == $COCKBLOCK_TYPE{'INITIAL'} || $prev_type == $COCKBLOCK_TYPE{'INTERMEDIATE'})) {
			$condom .= $cyphallic;
			my ($destroked, $strokecount) = $self->destroke($condom);
			$strokes += $strokecount;
			$dechoded .= $destroked;
		} else {
			carp "Error: $COCKBLOCK_TYPE_REVERSE{$prev_type} should not appear before $COCKBLOCK_TYPE_REVERSE{type}!";
		}

		$prev_type = $cockblock->{'TYPE'};
	}
	
	return ($dechoded, $strokes);
}

sub make_cockchain ($$$) {
	my ($self, $text, $size) = @_;
	
	# Take a string of chodes and split it into multiple cockblocks as needed to fit the line size.
	# Parameters:
	# [1] - Input text (as string)
	# [2] - Maximum number of characters in a line
	
	$Text::Wrap::columns = $size - $COCKBLOCK_PADDING;
	$Text::Wrap::huge = "overflow";

	my @cockblocks = split(/\n/, wrap("","",$text));
	my $sepmarker = $SEPARATOR . $KONTOL_CHODES{'CONT'} . "\n" . $KONTOL_CHODES{'MARK'} . $SEPARATOR;
	
	return 
		$KONTOL_CHODES{'START'} .
		$SEPARATOR .
		join($sepmarker, @cockblocks) .
		$SEPARATOR .
		$KONTOL_CHODES{'STOP'};
}

sub stroke ($$$) {
	# Take plaintext as a string and return a base64-encoded string.
	# Parameters:
	# [1] - Input text (as string)
	# [2] - Number of strokes (base64 rounds)
	my($self, $text, $count) = @_;
		
	$text = "${ESCAPE_SENTINEL}$text";

	while ($count > 0) {
		$text = encode_base64($text, "");
		chomp $text;
		$count -= 1;
	}

	return $text;
}

sub destroke($$) {
	# Take a string of text and Base64-decode it until the original text is received, and return both the original text and the number of Base64 rounds.
	# Parameters:
	# [1] - Input text (as string)

	my($self, $text) = @_;
	my $count = 0;
	
	while((length $text > 0) && ((substr $text, 0, 1) ne $ESCAPE_SENTINEL) && ((length $text) % 4 == 0) && ($text !~ /[^+\/=0-9A-Za-z]/)) {
		$text = decode_base64($text);
		$count += 1;
	}
	
	$text =~ s/^$ESCAPE_SENTINEL{0,}//;
	
	return ($text, $count);
}

sub cyphallicize ($$$;$) {
	# Take a string of text (probably base64) and convert it to a chode string (with no kontol chodes.)
	# Parameters:
	# [1] - Input text (as string)
	# [2] - Mode (thin/ASCII, wide/Unicode, mixed)
	# [3] (optional) - Variance. This is a decimal number from 0-1 which, when operating in mixed-chode-mode, is the chance that a specific chode will be thin (vs. wide.) If not given, defaults to 0.5.
	my($self, $input, $mode) = @_;
	
	my $variance = defined $_[3] ? $_[3] : 0.5;
	my @chodes;
	my $result;
	
	if ($mode == $CYPHALLIC_METHOD{"THIN"}) {
		foreach my $character (split("", $input)) {
			push @chodes, $thinchodes[ord $character];
		}
	}
	
	elsif ($mode == $CYPHALLIC_METHOD{"WIDE"}) {
		foreach my $character (unpack("(n)*", $input)) {
			$character = pack("U", $character);
			push @chodes, $widechodes[ord $character];
		}
	}
	elsif ($mode eq $CYPHALLIC_METHOD{"MIXED"}) {
		my $prev;
		foreach my $character (unpack("(A1)*", $input)) {
			if (rand() < $variance) {
				if (!defined $prev) {
					push @chodes, $thinchodes[ord $character];
				} else {
					push @chodes, $thinchodes[ord $prev];
					$prev = $character;
				}
			} else {
				if (!defined $prev) {
					$prev = $character;
				} else {
					$character = pack("U", (((ord $prev) << 8) | (ord $character)));
					push @chodes, $widechodes[ord $character];
					undef $prev;
				}
			}
		}
		if (defined $prev) { push @chodes, $thinchodes[ord $prev]; }
	}
	return join($SEPARATOR, @chodes);
}

sub decyphallicize($$) {
	# Take cockblock text (no kontol chodes) and return a string (which is probably base64.)
	# Parameters:
	# [1] - Input text (as string)

	my($self, $input) = @_;
	
	my @chodes = split(/$SEPARATOR/, $input);
	
	my $raw;

	foreach my $chode (@chodes) {
		if(exists $thinchodelist{$chode}) { $raw .= chr($thinchodelist{$chode}); }
		elsif(exists $widechodelist{$chode}) {
			$raw .= pack("n", $widechodelist{$chode});
		}
		else { carp "Unknown symbol: $chode!"; }
	}

	return $raw;
}

sub find_cockblocks($$) {
	# Take an input string and return an array reference of all the cockblocks found, in order of appearance.
	# Each element in the array reference is a hash reference containing two files: TYPE, and TEXT.
	# Parameters:
	# [1] - Text to search through

	my($self, $input) = @_;
	
	my $cockblocks = [];
	
	# Construct a search pattern. Essentially, we're looking for anything starting with a valid chode in the [BEGIN] set, and ending with one in the [END] set.
	
	my $pattern =
		"(" .
			join("|", map(quotemeta, @{$KONTOL_CHODES{'[BEGIN]'}})) .
		")" .
		$SEPARATOR .
		"(.*?)" .
		$SEPARATOR .
		"(" .
			join("|", map(quotemeta, @{$KONTOL_CHODES{'[END]'}})) .
	")";
	
	while ($input =~ /$pattern/g) {
		my $cockblock_type;
		
		$cockblock_type = $COCKBLOCK_TYPE{"SINGLETON"} if ($1 eq $KONTOL_CHODES{'START'} && $3 eq $KONTOL_CHODES{'STOP'});
		$cockblock_type = $COCKBLOCK_TYPE{"INITIAL"} if ($1 eq $KONTOL_CHODES{'START'} && $3 eq $KONTOL_CHODES{'CONT'});
		$cockblock_type = $COCKBLOCK_TYPE{"INTERMEDIATE"} if ($1 eq $KONTOL_CHODES{'MARK'} && $3 eq $KONTOL_CHODES{'CONT'});
		$cockblock_type = $COCKBLOCK_TYPE{"FINAL"} if ($1 eq $KONTOL_CHODES{'MARK'} && $3 eq $KONTOL_CHODES{'STOP'});
		
		push @{$cockblocks}, {"TYPE" => $cockblock_type, "TEXT" => $2};
	}
	
	return $cockblocks;
}

sub bytes_to_string($$) {
	return join("", @{$_[1]});
}

sub string_to_bytes($$) {
	my @byte_array = unpack("(A1)*", $_[1]);
	return \@byte_array;
}

1;