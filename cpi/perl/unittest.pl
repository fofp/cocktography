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
        "8" => "Vm0xNGEwMUdWWGhWV0doVFYwZDRWVmxVU205V1ZteDBaVVYwYWxKc1ZqTlhXSEJUVlVaV1ZVMUVhejA9",
        "10" => "Vm0wd2VFNUhSWGROVldSWFYwZG9WMVl3Wkc5V1JsbDNXa1JTVjFadGVGWlZNakExVmpGYWRHVkVRbUZXVmxsM1dWZDRTMk14V25GVWJHaFlVMFZLVlZac1ZtRldNVnBXVFZWV2FHVnFRVGs9"
    },
    "unicode" => {
        "1" => "D/CfkI7wn5CU",
        "2" => "RC9DZmtJN3duNUNV",
        "8" => "Vm0xNGEwMUdVbkpPVm1SVVlUSlNjVlV3V2t0amJGWnpZVVZPVmxKc1NsWlZNbmhQVkd4YWMxTnVjRmRpV0UweFZtcEdkMDVyTVVWaGVqQTk="
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
            "2" => "8=wm=D 8==wD 8====D 8m=D~ 8==D~~~ 8w=D~~ 8====D~~ 8mD~~~ 8wD 8w=D~~ 8w==D 8==D 8==w=D~ 8=mw=D",
            "8" => "8=wm=D 8mD~~ 8===D~~~~ 8=wD~~~~ 8m=D~~~ 8m=D~ 8====D~~ 8=D~ 8=D~~ 8====D~~~~ 8==D~~~~ 8===D 8==D~~ 8==D~~ 8====D~~ 8wD~~~ 8==D~~ 8mD~~ 8=wD~~~~ 8===D 8==D 8mD~~ 8====D~~~ 8w==D~ 8=D~~ 8m==D~~~~ 8====D 8==wD 8==D~~ 8mD~~ 8===D~~~~ 8m=D~~~ 8mD~~ 8==D~~~~ 8w===D~~~ 8=wD~~~~ 8=w==D 8mD~~ 8w=D~~~ 8m==D~~~~ 8wD 8=D 8====D 8w==D~~ 8w=D 8=ww=D\n8wmD 8mD~~ 8mD~~ 8w==D~ 8=D~~ 8w==D~ 8==D~~ 8m=D~~~ 8m==D~~ 8=D~~~ 8w=D~~~ 8m==D~~~~ 8m===D~~~ 8wD~ 8===D~ 8wD~~~ 8m==D~~~ 8=m=D 8=D~ 8mD~~~ 8==D~~~~ 8mD~~ 8===D~ 8mD~~ 8w=D 8mD~~ 8w=D~~~ 8m==D~~~~ 8mD~~ 8====D~~~~ 8==D~~~~ 8mD~~ 8wD~~~ 8=D 8m===D~~ 8=wD 8=w=D~~~ 8=mw=D"
        },
        "unicode" => {
            "1" => "8=wm=D 8====D 8==wD~~~~ 8==D~~~ 8===D~~~ 8m=D~~ 8mD~ 8=wD~~ 8=D~~ 8w=D~ 8=w==D 8==D~~~ 8==D~~~~ 8=mw=D",
            "2" => "8=wm=D 8==wD 8==D~~~ 8=w=D~~~ 8====D 8m==D~~~~ 8===D~~~~ 8wD 8mD~~~ 8m=D~ 8w=D~~~~ 8===D 8=D~~~~ 8m=D~ 8==D~~~~ 8m=D~ 8mD~~ 8=mw=D",
            "6" => "8=wm=D 8mD~~ 8===D~~~~ 8m=D~~~ 8m=D~~ 8====D~~~~ 8====D~~~ 8==wD 8m==D~ 8m=D~ 8mD~~ 8===D 8wD~ 8w=D 8w===D~~~ 8==wD 8m===D~~~ 8==D~~~~ 8=wD~~~~ 8m==D~~~~ 8m==D~~ 8=D~~~ 8===D~ 8mD~~ 8=mD 8w=D 8=D~ 8m=D~ 8mD~~ 8==wD 8===D~ 8mD~~~ 8mD~~ 8==D~~~~ 8w===D~~~ 8m=D~~~ 8m=D 8wD~ 8===D~ 8m==D~~~~ 8=mD 8=m=D 8w=D~ 8w===D~ 8==D~~ 8w=D~~ 8=ww=D\n8wmD 8m==D~~~ 8====D~~~~ 8w=D~~~ 8mD~~ 8m===D~~ 8====D~~~ 8=D~~ 8m=D~ 8m=D~~ 8w=D~~~ 8=D~ 8w=D 8m=D~~~~ 8=wD~~~~ 8==w=D~ 8=mw=D"
        }
    },
    "wide" => {
        "ascii" => {
            "1" => "8=wm=D 8mD';,, B=m=D BnD``; BnD,;' 8=mw=D",
            "2" => "8=wm=D BnD`;; 8uD,,~ Bu=D,, 8uD~'', 8=D'''' BmuwD` 8=mw=D",
            "10" => "8=wm=D 8mm=wD BnuD;~ 8=uD~` BuwmnD 8mnD`' 8=D'`;; 8=D',;` 8mD`~; BwuD,~ 8wnmD' 8=D';;~ 8mD;',; 8nD~`;' 8mD'~'` Bnm=D, B=wD`' 8=D'~`` BmmD,, 8=D`;'' 8=D;'`~ 8mD,~,, 8=D~',~ 8nwD;' 8=D,~,` 8nD~~;` 8=D'~~ Bu==D, 8nw=D' 8mD'~~, Bw=mD~ BmD`` 8mD`,' 8mm=wD 8nD`;,~ BwmmD, 8=D`~`` 8=D'',~ 8wnD;' 8mD'''' 8mD'`;` 8mm=wD BmuD,` 8==uD` B=wn=D 8=ww=D\n8wmD 8=D;,~` B=D,,' 8=D,;;, 8u=D~ 8=D;~', 8nuw=D 8=D`~`~ 8mD,;,; BmuD,~ 8=D;;~; B=wD'` 8mD,;`' BwuD,~ BwD''' 8wwD,~ 8mD`~;; B=u=D' BmnwuD 8mD~~,` 8mD,,~~ BuwmnD Bm=wD, 8=D;~', 8=D``'; 8mD~~,` BmD~'` 8nw=D' BnwD,` 8=mw=D"
        },
        "unicode" => {
            "1" => "8=wm=D BnmD;` 8mD~;~` 8=D~~,~ 8=D;`,` 8mD;~,~ 8uwD~~ 8=mw=D",
            "2" => "8=wm=D 8nD'', 8mD;';~ Bm=D;; 8wD~``~ 8mD;'~~ 8=uD` 8mnD`' BnwD~' 8=mw=D",
            "8" => "8=wm=D 8mm=wD B=D`;` 8mD~,' BwnD,` 8muD,, 8mD'~;` 8u==D, 8nD~'~, 8mm=wD 8wwmD~ Bw==D' 8mD;'`; BnD,,; 8mD'`,~ BwuD,~ 8nD``;' 8=D;~', 8wwD~' BmuD 8mD~`;` 8nD``;~ 8uD~`~' Bw==D' 8uD,;;; 8mm=wD 8uD';~` 8wwD,~ BnmwuD 8mD'~~, Bw=mD~ BnD``; 8uD~`~; 8=D'',~ 8=uD~, BwmmD, 8wD~~`, 8=D';`~ 8nD~~;` 8mD``;; 8nD~'`; B=mm=D 8=D''~; 8wnD`, 8mD`~;; 8=ww=D\n8wmD 8===D; 8wD`~~ 8nuD;; 8nD;``` 8=wD~' 8=D`~`~ 8=D`~,' 8uD~~`, 8nD'~;; 8n=wuD 8=mw=D"
        }
    }
);

foreach my $load_type (keys %test_cumshots) {
    foreach my $stroke_count (keys %{$test_cumshots{$load_type}}) {
        is($penis->stroke($test_sperm{$load_type}, $stroke_count), $test_cumshots{$load_type}{$stroke_count}, "stroke() / input: $load_type / strokes: $stroke_count");
        is(($penis->destroke($test_cumshots{$load_type}{$stroke_count}))[0], $test_sperm{$load_type}, "destroke() / input: $load_type / strokes: $stroke_count");

        my $mixed_cock_chain = $penis->enchode_string($test_sperm{$load_type}, $stroke_count, $chode_modes{"mixed"}, 340);
        is_deeply([$penis->dechode_string($mixed_cock_chain)], [($test_sperm{$load_type}, $stroke_count)], "mixed-mode enchode/dechode_string / type: $load_type / strokes: $stroke_count");
    }
}

foreach my $chode_mode (keys %test_cockchains) {
    foreach my $load_type (keys %{$test_cockchains{$chode_mode}}) {
        foreach my $stroke_count (keys %{$test_cockchains{$chode_mode}{$load_type}}) {
            is_deeply($penis->enchode_string($test_sperm{$load_type}, $stroke_count, $chode_modes{$chode_mode}, 340), $test_cockchains{$chode_mode}{$load_type}{$stroke_count}, "enchode_string() / mode: $chode_mode / input: $load_type / strokes: $stroke_count");
            is_deeply([$penis->dechode_string($test_cockchains{$chode_mode}{$load_type}{$stroke_count})], [($test_sperm{$load_type}, $stroke_count)], "dechode_string() / mode: $chode_mode / output: $load_type / strokes: $stroke_count");
        }
    }
}