# Arquivo: refatorarTextos.awk
# Descrição: Remove textos nas linhas de código JSP, trocando-as por
#            códigos de dicionário.

@include "sliic/libLocProperties"
@include "sliic/libParserFilePath"
@include "sliic/libConvIsoUtf"
@include "sliic/libInsertTaglib"
@include "sliic/libJavaParser"
@include "libColumTag"
@include "libRefatorarTextos"

BEGIN {
  findFiles(msgs_paths);
  nextTaglib = "<%@ taglib prefix=\"n\" uri=\"http://www.nextframework.org/tag-lib/next\"%>";
}

BEGINFILE {
  parserFilePath(FILENAME, aMetaFile);
  MsgProp = locProperties(aMetaFile, msgs_paths);
  convertIso8859ToUtf8();
  print "\n==== Refatoração de textos ====\n" > "/dev/tty";
  print "Arquivo:", FILENAME > "/dev/tty";
  print "Properties:", MsgProp > "/dev/tty";

}

/taglib/ {
  insereTaglib();
}

/t:property.+label="\w+/ {
}

/n:column.+header="\w+/ {
  if (!MsgProp) {
    print "Erro: Nenhum arquivo de dicionário encontrado." > "/dev/tty";
     nextfile;
  }
  id = getId();

  fmt = removerIdentacao($0);
  print " Refatorar:", fmt > "/dev/tty";
    
  checkTaglib(nextTaglib);
  initColumn($0);
  codigo = getColumnCod(aMetaFile, id);
  $0 = getColumni18n(codigo);
  fmt = removerIdentacao($0);
  printf " Para: %s\n", fmt > "/dev/tty";

  codigo = getColumCodComTexto(aMetaFile, id);
  if ("inplace::begin" in FUNCTAB) {
    printf ("%s\r", codigo) >> MsgProp;
  }
  printf " Código: %s\n\n", codigo  > "/dev/tty";
  endColumn();
}

{
  if ("inplace::begin" in FUNCTAB) {
    printf "%s%s", $0, RT;
  }
}

END {
  convertUtf8ToIso8859();
}
