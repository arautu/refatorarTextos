# Arquivo: libPropertyTag.awk
# Refatora para i18n textos em tags property.

function refatorarPropertyTag(instrucao, id, aMetaFile, campos,  texto, i) {
  fieldpat = "(:\\w+)|(\\w+=)|(\"[^\"]*\")";
  patsplit(instrucao, atag, fieldpat, seps);
  
  for (i=1; i <= length(atag); i++) {
    if (atag[i] ~ campos"=") {
      texto = atag[++i];
      atag[i] = sprintf("\"<n:messageViewPrefix('%s')>\"", id);
    }
  }
  for (i in seps) {
    prt_instrucao = prt_instrucao sprintf ("%s%s", atag[i], seps[i]);
  }
  gsub("\"", "", texto);
  prt_codigo = aMetaFile["module"] "." aMetaFile["file"] "." id "=" texto;
}

function getInstrucao() {
  if (!prt_instrucao) {
    print "Erro: Deve-se chamar refatorarPropertyTag antes";
    return "";
  }
  return prt_instrucao;
}

function getCodigo() {
  if (!prt_codigo) {
    print "Erro: Deve-se chamar refatorarPropertyTag antes";
    return "";
  }
  return prt_codigo;
}

# Salva parâmetros goblais.
function prt_init() {
  if ("sorted_in" in PROCINFO) {
    prt_save_sorted = PROCINFO["sorted_in"];
  }
  PROCINFO["sorted_in"] = "@ind_str_asc";
}

# Restabelece valores de variáveis goblais.
function prt_end() {
  if (prt_save_sorted) {
    PROCINFO["sorted_in"] = prt_save_sorted;
    prt_save_sorted = "";
  }
}
