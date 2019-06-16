use diagnostics;
use warnings;
use strict;
use Test::More qw(no_plan);

use FindBin qw($Bin);
use lib $Bin;

require Cocktography;

my $penis = Cocktography->new();

my %test_sperm = (
    "ascii" => "penis",
    "unicode" => "🐎🐔"
);

my %test_cumshots = (
    "ascii" => {
        "1" => "D3Blbmlz",
        "2" => "RDNCbGJtbHo=",
    },
    "unicode" => {
        "1" => "D/CfkI7wn5CU",
        "2" => "RC9DZmtJN3duNUNV"
    }
);

my %chode_modes = (
    "narrow" => 1,
    "wide" => 2,
    "mixed" => 3
);

my %test_cockchains = (
    "narrow" => {
        "ascii" => {
            "1" => "8=wm=D 8====D 8w=D~~~~ 8w==D~~ 8===D~ 8w=D~~ 8===D~~~~ 8===D~ 8m=D~~~~ 8=mw=D",
            "2" => "8=wm=D 8==wD 8====D 8m=D~ 8==D~~~ 8w=D~~ 8====D~~ 8mD~~~ 8wD 8w=D~~ 8w==D 8==D 8==w=D~ 8=mw=D"
        },
        "unicode" => {
            "1" => "8=wm=D 8====D 8==wD~~~~ 8==D~~~ 8===D~~~ 8m=D~~ 8mD~ 8=wD~~ 8=D~~ 8w=D~ 8=w==D 8==D~~~ 8==D~~~~ 8=mw=D",
            "2" => "8=wm=D 8==wD 8==D~~~ 8=w=D~~~ 8====D 8m==D~~~~ 8===D~~~~ 8wD 8mD~~~ 8m=D~ 8w=D~~~~ 8===D 8=D~~~~ 8m=D~ 8==D~~~~ 8m=D~ 8mD~~ 8=mw=D"
        }
    },
    "wide" => {
        "ascii" => {
            "1" => "8=wm=D 8mD';,, B=m=D BnD``; BnD,;' 8=mw=D",
            "2" => "8=wm=D BnD`;; 8uD,,~ Bu=D,, 8uD~'', 8=D'''' BmuwD` 8=mw=D"
        },
        "unicode" => {
            "1" => "8=wm=D BnmD;` 8mD~;~` 8=D~~,~ 8=D;`,` 8mD;~,~ 8uwD~~ 8=mw=D",
            "2" => "8=wm=D 8nD'', 8mD;';~ Bm=D;; 8wD~``~ 8mD;'~~ 8=uD` 8mnD`' BnwD~' 8=mw=D"
        }
    }
);

foreach my $load_type (keys %test_cumshots) {
    foreach my $stroke_count (keys %{$test_cumshots{$load_type}}) {
        is($penis->stroke($test_sperm{$load_type}, $stroke_count), $test_cumshots{$load_type}{$stroke_count}, "stroke() / input: $load_type / strokes: $stroke_count");
        is(($penis->destroke($test_cumshots{$load_type}{$stroke_count}))[0], $test_sperm{$load_type}, "destroke() / input: $load_type / strokes: $stroke_count");

        my $mixed_cock_chain = $penis->enchode_string($test_sperm{$load_type}, $stroke_count, $chode_modes{"mixed"}, 326);
        is($penis->dechode_string($mixed_cock_chain), $test_sperm{$load_type}, "mixed-mode enchode/dechode_string / type: $load_type / strokes: $stroke_count");
    }
}

foreach my $chode_mode (keys %test_cockchains) {
    foreach my $load_type (keys %{$test_cockchains{$chode_mode}}) {
        foreach my $stroke_count (keys %{$test_cockchains{$chode_mode}{$load_type}}) {
            is($penis->enchode_string($test_sperm{$load_type}, $stroke_count, $chode_modes{$chode_mode}, 326), $test_cockchains{$chode_mode}{$load_type}{$stroke_count}, "enchode_string() / mode: $chode_mode / input: $load_type / strokes: $stroke_count");
            is($penis->dechode_string($test_cockchains{$chode_mode}{$load_type}{$stroke_count}), $test_sperm{$load_type}, "dechode_string() / mode: $chode_mode / output: $load_type / strokes: $stroke_count");
        }
    }
}