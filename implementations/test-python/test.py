# -*- coding: utf-8 -*-
from cpi import cpi

cocktographic = cpi.Cocktography()
strokes = 0


def varied_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(
            cocktographic.stroke(t, strokes), cpi.CyphallicMethod.MIXED_CHODE),
        340)


def unigram_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(
            cocktographic.stroke(t, strokes), cpi.CyphallicMethod.THIN_CHODE),
        340)


def digram_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(
            cocktographic.stroke(t, strokes), cpi.CyphallicMethod.WIDE_CHODE),
        340)


# text = b"Test sentence for the widechode edition of cocktographic messaging."
text = bytearray(
    u"This is an example of mixed chodes in no-stroke enchoding. Ḥ̙E̱̗̞ ̷̙̱͓̜̲C̴̰̫͈̜̖̠̦OM͕̲ÈS̮̰̜͈̹",
    'utf-8')
# text = text + b" " + text

print digram_chain(text)
print
print unigram_chain(text)
print
print varied_chain(text)
print
print cocktographic.decyphallicize(
    "BuwD; B=D, 8mD; BmD~ B=D` B=D`~ 8nD 8mD;` 8nD' BuD 8nD 8nD`~ BnuD BunD 8uD~, 8nD 8wD; 8uD; 8mD,` 8nD` 8mD~, BmD; BnD~; 8wD;'; BwD', BmwD 8unD' Bw=D BnD, B=D~ 8wD'~ BnD'` 8uD'"
)
print
print cocktographic.decyphallicize(
    "8=wm=D 8wD~ 8=D B=D, 8mD; 8=D 8unD 8=D 8w=D~ 8mD'; 8mD 8mD;` 8nD' 8wD 8=D; 8mD 8=D~~ 8==D~ BnuD 8=D~~~ 8wD~~~ 8==D 8===D 8nD 8wD; 8==D~ BwD' 8==D 8w=D~ BmD, 8===D~~~ BmD; 8==D 8=D~~~ 8m=D~~ BmD' 8===D~~ 8m==D~ 8w=D 8w===D~ 8wD~~~ Bw=D 8mD 8===D~~~~ B=D~ 8=mD 8w=D BnD'` 8w=D~ 8===D~~ 8=mw=D"
)
text = "PINGAS 8=wm=D 8wD~ 8=D B=D, 8mD; 8=D 8unD 8=D 8w=D~ 8mD'; 8mD 8mD;` 8nD' 8wD 8=D; 8mD 8=D~~ 8==D~ BnuD 8=D~~~ 8wD~~~ 8==D 8===D 8nD 8wD; 8==D~ BwD' 8==D 8w=D~ BmD, 8===D~~~ BmD; 8==D 8=D~~~ 8m=D~~ BmD' 8===D~~ 8m==D~ 8w=D 8w===D~ 8wD~~~ Bw=D 8mD 8===D~~~~ B=D~ 8=mD 8w=D BnD'` 8w=D~ 8===D~~ 8=mw=D FLARP!!!"
(chodes_begin,
 chodes_end), (cyphallic_begin,
               cyphallic_end), t = cocktographic.find_cockblock(text)
print text
print t
if t == cpi.CockblockType.SINGLETON:
    print "PRE-CHODE TEXT: " + text[:chodes_begin]
    print "BEGINNING KONTOL: " + text[chodes_begin:cyphallic_begin]
    print "CYPHALLIC TEXT: " + text[cyphallic_begin:cyphallic_end]
    print "ENDING KONTOL: " + text[cyphallic_end:chodes_end]
    print "POST_CHODE TEXT: " + text[chodes_end:]

print cocktographic.enchode(bytearray(b"dicks"), 2, 1, 340)
print
dechoded = cocktographic.dechode(b"8=wm=D 8wm===D BmD;; 8==D~ 8=mD 8mD' 8=mD 8mD 8w=D 8nD` 8=D 8m=D~~~ BmuD 8mD;' 8=D 8mD 8mD~, 8mD 8nD;; B=mmD 8===D 8mD 8=D~~~ 8wD~~~ 8uD~, 8=D 8uD BnD 8mD B=nD 8=w==D~~~~ 8=mD 8nD,~ 8==D 8=D;' 8mD BmD~ 8=D~~~ 8wD~~~ 8uD~, 8==D~ 8w=D~ B=u=D 8mD 8w==D B=ww==nD BmD`;~;' B=umm==D 8=D~ B=ww==nD B=w==n=D B=ww==nD B=u=nm=D BwD;`;;' 8nu=D`` 8=ww=D 8wmD BnD,,~'' B=umm==D B=ww==nD BnD'`,~' B=u=m==D B=ww==nD B=unm==D B=ww==nD B=w==nmD 8=D`~,`` B=w=mm=D B=ww==nD BnD`,;,~ B=w===mD B=ww=m=D 8wD~',`~ B=unm==D B=ww==nD B=u=n==D BwD;`;;, B=ww==nD B=uwmm=D 8m=D 8====D~~~~ BwD;;;', B=ww==nD B=w==nmD 8=D~ B=ww=m=D 8uD'~''` B=ww==nD B=w==m=D B=ww==nD B=w==mnD B=ww==nD B=unm==D BwD;;;~` 8=ww=D 8wmD BwD;`,;, 8=mw=D")
for text, count in dechoded:
    print "[{} strokes]: {}".format(count, text)
