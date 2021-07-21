# Arquivo: libRefatorarTextos.awk
# Descrição: Funções de refatorarTextos.awk

# Variáveis Globais
# prt_instrucao
# prt_codigo

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

# Refatora o campo label de property
# De:   <t:property ... label="texto">
# Para: <t:property ... label="${n:messageViewPrefix('id')}">
function propertyTag(instrucao, id, aMetaFile) {
  tag_refatorarTextoCampo(instrucao, id, aMetaFile, "label");
}

# Refatora o campo header de column
# De:   <n:column header="texto">
# Para: <n:column header="${n:messageViewPrefix('id')}">
function columnTag(instrucao, id, aMetaFile) {
  tag_refatorarTextoCampo(instrucao, id, aMetaFile, "header");
}

# Refatora textos entre tags div
# De:   <div>texto<\div>
# Para: <div>${n:messageViewPrefix('id')}<\div>
function divTag(instrucao, id, aMetaFile) {
  tag_refatorarTextoTag(instrucao, id, aMetaFile);
}

# Refatora textos entre tags panel
# De:   <n:panel>texto<\n:panel>
# Para: <n:panel>${n:messageViewPrefix('id')}<\n:panel>
function panelTag(instrucao, id, aMetaFile) {
  tag_refatorarTextoTag(instrucao, id, aMetaFile);
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

# Refatora instruções com texto entre tags, ex: <tag>texto<\tag> e monta
# o código de dicionário correspondente.
function tag_refatorarTextoTag(instrucao, id, aMetaFile,   texto, i, atag, seps, fieldpat) {
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
function tag_refatorarTextoCampo(instrucao, id, aMetaFile, campos,  texto, i, atag, seps, fieldpat) {
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
