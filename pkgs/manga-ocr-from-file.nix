{ manga-ocr, writers }:
writers.writePython3Bin "manga-ocr-from-file" { libraries = [ manga-ocr ]; } ''
  import sys
  from manga_ocr import MangaOcr
  mocr = MangaOcr()

  text = mocr(sys.argv[1])
  print(text)
''
