# Arquivo: refatorarTextos.awk
# Descrição: Remove textos nas linhas de código JSP, trocando-as por
#            códigos de dicionário.

@include "sliic/libLocProperties"
@include "sliic/libParserFilePath"
@include "sliic/libConvIsoUtf"
@include "sliic/libInsertTaglib"
@include "sliic/libJavaParser"
@include "libRefatorarTextos"

BEGIN {
  FPAT = "(<\\w:?\\w+)";
  findFiles(msgs_paths);
  nextTaglib = "<%@ taglib prefix=\"n\" uri=\"http://www.nextframework.org/tag-lib/next\"%>";
}

BEGINFILE {
  oneShot = 0;
  parserFilePath(FILENAME, aMetaFile);
  MsgProp = locProperties(aMetaFile, msgs_paths);
  convertIso8859ToUtf8();
}

/taglib/ {
  insereTaglib();
}

(/label="\w+/ && key="label") ||
(/labelBotao="\w+/ && key="labelBotao") ||
(/labelTag="\w+/ && key="labelTag") ||
(/descricao="\w+/ && key="descricao") ||
(/header="\w+/ && key="header") ||
(/value="\w+/ && key="value") ||
(/confirmationMessage="\w+/ && key="confirmationMessage") ||
(/legend="\w+/ && key="legend") ||
(/title="\w+/ && key="title") ||
(/>\s?(\${.*})?\s?[[:alpha:]].+/ && key="tag") {
  if (!MsgProp) {
    print "Erro: Nenhum arquivo de dicionário encontrado." > "/dev/tty";
    nextfile;
  }
  if (OldFilename != FILENAME) {
    if (!oneShot) {
      oneShot = 1;
      rewind();
      checkTaglib(nextTaglib);
      print "\n==== Refatoração de textos ====\n" > "/dev/tty";
      print "Arquivo:", FILENAME > "/dev/tty";
      print "Properties:", MsgProp > "/dev/tty";
    }
  } else {
    fmt = removerIdentacao($0);
    print " Instrução:", fmt > "/dev/tty";
    id = getId();

    switch(key) {
      case "tag":
        refatorarTextoTag($0, id, aMetaFile);
        break;
      default :
        refatorarTextoCampo($0, id, aMetaFile, key);
        break;
    }

    printf " Refatorar:\t%s\n", fmt > "/dev/tty";
    $0 = getInstrucao();
    fmt = removerIdentacao($0);
    printf " Para:\t\t%s\n", fmt > "/dev/tty";

    codigo = getCodigo(); 
    if ("inplace::begin" in FUNCTAB) {
      printf ("%s\r\n", codigo) >> MsgProp;
    }
    printf " Código: %s\n\n", codigo  > "/dev/tty";

    findWhereFileIsIncluded(aMetaFile["file"]);
  }
}

{
  if ("inplace::begin" in FUNCTAB) {
    printf "%s%s", $0, RT;
  }
}

ENDFILE {
  OldFilename = FILENAME;
}

END {
  convertUtf8ToIso8859();
}
