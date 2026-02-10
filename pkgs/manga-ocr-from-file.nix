{ python3Packages, writers }:
writers.writePython3Bin "manga-ocr-from-file" { libraries = [ python3Packages.manga-ocr ]; } ''
  import sys
  from manga_ocr import MangaOcr
  mocr = MangaOcr()

  text = mocr(sys.argv[1])
  print(text)
''
