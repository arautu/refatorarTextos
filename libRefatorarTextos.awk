# Arquivo: libRefatorarTextos.awk
# Descrição: Funções de refatorarTextos.awk

# Variáveis Globais
# prt_instrucao
# prt_codigo
# prt_findIncludes 

BEGINFILE {
  prt_findIncludes = "";
}

# Interage com o usuário, através do terminal, para obter o identificador
# único do código de dicionário.
# Retorno:
# O identificador do código de dicionário.
function getId(   Oldrs, id) {
  Oldrs = RS;
  RS = "\n";

  printf " Entre o id do código: " > "/dev/tty";
  getline id < "/dev/stdin";

  RS = Oldrs;

  return id;
} 

# Retorna a instrução refatorada
# Retorno:
# * Instrução refatorada
function getInstrucao() {
  if (!prt_instrucao) {
    print "Erro: Não há instrução refatorada";
    return "";
  }
  return prt_instrucao;
}

# Retorna o código de dicionário
# Retorno:
# * Código de dicionário
function getCodigo() {
  if (!prt_codigo) {
    print "Erro: Não há instrução refatorada";
    return "";
  }
  return prt_codigo;
}

# Encontra os arquivos que usam a diretiva 'include' para incluir um
# determinado arquivo. São dois tipos de tags procurados:
# <jps:include ... />
# <%@include ... %>
# Argumentos:
# * file: Nome do arquivo JSP que será procurado.
# Retorno:
# * Retorna uma mensagem na tela caso encontre o arquivo "file" sendo citado
# em instruções 'include', além do caminho e nome destes arquivos.
function findWhereFileIsIncluded(file,  i, includes, tmp, Oldrs) {
  if (prt_findIncludes) {
    return
  }
  prt_findIncludes = 1;
  Oldrs = RS;
  RS = "\n";
  
  absPath = absolutePath(ARGV[1]);
  if (!absPath) {
    exit 1;
  }

  grep = sprintf("grep -r -E -l --include=*.jsp \"<\\S+include.*/%s\" %s", file, absPath);
  print grep |& "sh";
  close("sh", "to");

  while (("sh" |& getline tmp) > 0) {
    includes[i++] = tmp;
  }
  close("sh");

  if (isarray(includes)) {
    printf "Atenção: Há %s arquivos que incluem o arquivo %s.\n", length(includes), FILENAME > "/dev/tty";
    for (i in includes) {
      printf " %s\n", includes[i] > "/dev/tty";
    }
    printf "\n" > "/dev/tty";
  }
  RS = Oldrs;
}

# Refatora instruções com texto entre tags, ex: <tag>texto<\tag> e monta
# o código de dicionário correspondente.
function refatorarTextoTag(instrucao, id, aMetaFile,   texto, i, atag, seps, fieldpat) {
  prt_init();
  fieldpat = "(<[^>]+>)|(\\${[^}]+})|([^$<]+)";
  patsplit(instrucao, atag, fieldpat, seps);
  prt_instrucao = "";
  prt_codigo = "";

  for (i in atag) {
    if (atag[i] ~ /^\s?\w+/) {
      texto = atag[i];
      gsub(/^\s|\s$/, "", texto);
      atag[i] = gensub(/(^\s)?\S+( \S+)*(\s$)?/,sprintf("\\1${n:messageViewPrefix('%s')}\\3", id), "g", atag[i]);
    }
  }
  for (i in seps) {
    prt_instrucao = prt_instrucao sprintf ("%s%s", atag[i], seps[i]);
  }
  prt_codigo = aMetaFile["module"] "." aMetaFile["file"] "." id "=" texto;
  prt_end();
}

# Refatora instruções que o texto se encontra em um campo da tag,
#  ex: <tag campo="texto"> e monta o código de dicionário correspondente.
function refatorarTextoCampo(instrucao, id, aMetaFile, campos,  texto, i, atag, seps, fieldpat) {
  prt_init();
  fieldpat = "(\\w+=)|(\"[^\"]*\")";
  patsplit(instrucao, atag, fieldpat, seps);
  prt_instrucao = "";
  prt_codigo = "";
  
    for (i=1; i <= length(atag); i++) {
      if (atag[i] ~ campos"=") {
        texto = atag[++i];
        atag[i] = sprintf("\"${n:messageViewPrefix('%s')}\"", id);
      }
    }
  for (i in seps) {
    prt_instrucao = prt_instrucao sprintf ("%s%s", atag[i], seps[i]);
  }
  gsub("\"", "", texto);
  prt_codigo = aMetaFile["module"] "." aMetaFile["file"] "." id "=" texto;
  prt_end();
}

# Salva parâmetros goblais.
function prt_init() {
  if ("sorted_in" in PROCINFO) {
    prt_save_sorted = PROCINFO["sorted_in"];
  }
  PROCINFO["sorted_in"] = "@ind_num_asc";
}

# Restabelece valores de variáveis goblais.
function prt_end() {
  if (prt_save_sorted) {
    PROCINFO["sorted_in"] = prt_save_sorted;
    prt_save_sorted = "";
  }
}
