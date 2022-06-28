 del *.prg
 java -jar "c:\c64\tools\kickassembler\kickass.jar" slug_vs_lettuce.asm
 if not exist slug_vs_lettuce.prg goto abort
 c:\c64\tools\exomizer\win32\exomizer.exe sfx $4000 slug_vs_lettuce.prg -o slug_vs_lettuce.prg
 c:\c64\tools\vice\x64sc.exe slug_vs_lettuce.prg 
 abort:
 