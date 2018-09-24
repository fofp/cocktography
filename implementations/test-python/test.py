from cpi import cpi

cocktographic = cpi.Cocktography()
def varied_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(cocktographic.stroke(t, 1),
                                   cpi.CyphallicMethod.varied), 340)
def unigram_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(cocktographic.stroke(t, 1),
                                   cpi.CyphallicMethod.unigram), 340)
def digram_chain(t):
    return cocktographic.make_cockchain(
        cocktographic.cyphallicize(cocktographic.stroke(t, 1),
                                   cpi.CyphallicMethod.digram), 340)
text = b"Test sentence for the widechode edition of cocktographic messaging"
text = text + b" " + text

for cockblock in digram_chain(text): print cockblock


for cockblock in unigram_chain(text): print cockblock
for cockblock in varied_chain(text): print cockblock

print cocktographic.decyphallicize("BuwD; B=D, 8mD; BmD~ B=D` B=D`~ 8nD 8mD;` 8nD' BuD 8nD 8nD`~ BnuD BunD 8uD~, 8nD 8wD; 8uD; 8mD,` 8nD` 8mD~, BmD; BnD~; 8wD;'; BwD', BmwD 8unD' Bw=D BnD, B=D~ 8wD'~ BnD'` 8uD'")
print cocktographic.decyphallicize("8=wm=D 8wD~ 8=D B=D, 8mD; 8=D 8unD 8=D 8w=D~ 8mD'; 8mD 8mD;` 8nD' 8wD 8=D; 8mD 8=D~~ 8==D~ BnuD 8=D~~~ 8wD~~~ 8==D 8===D 8nD 8wD; 8==D~ BwD' 8==D 8w=D~ BmD, 8===D~~~ BmD; 8==D 8=D~~~ 8m=D~~ BmD' 8===D~~ 8m==D~ 8w=D 8w===D~ 8wD~~~ Bw=D 8mD 8===D~~~~ B=D~ 8=mD 8w=D BnD'` 8w=D~ 8===D~~ 8=mw=D")
text = "PINGAS 8=wm=D 8wD~ 8=D B=D, 8mD; 8=D 8unD 8=D 8w=D~ 8mD'; 8mD 8mD;` 8nD' 8wD 8=D; 8mD 8=D~~ 8==D~ BnuD 8=D~~~ 8wD~~~ 8==D 8===D 8nD 8wD; 8==D~ BwD' 8==D 8w=D~ BmD, 8===D~~~ BmD; 8==D 8=D~~~ 8m=D~~ BmD' 8===D~~ 8m==D~ 8w=D 8w===D~ 8wD~~~ Bw=D 8mD 8===D~~~~ B=D~ 8=mD 8w=D BnD'` 8w=D~ 8===D~~ 8=mw=D FLARP!!!"
__, (cyphallic_begin, cyphallic_end), type = cocktographic.find_cockblock(text)
print text
print type
if type == cpi.CockblockType.singleton:
    print text[:cyphallic_begin]
    print text[cyphallic_begin:cyphallic_end]
    print text[cyphallic_end:]
