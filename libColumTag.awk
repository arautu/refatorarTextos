# Arquivo: libColumTag.awk 
# Refatora para i18n textos em tags column.

# Variáveis estáticas
# cot_atag
# cot_seps
# cot_codigo
# cot_save_sorted

# Fragmenta a instrução em campos
# Argumentos:
# * instrucao - Instrução contendo 'n:column ... header=...'.
function initColumn(instrucao,    fieldpat) {
  fieldpat = "(:\\w+)|(\\w+=)|(\"[^\"]*\")";
  patsplit(instrucao, cot_atag, fieldpat, cot_seps);
}

# Elimina variáveis estáticas
function endColumn() {
  delete cot_atag;
  delete cot_seps;
  cot_codigo = "";
}

# Refatora instruções do tipo <n:column ... header="texto" ...> para
# <n:column ... header="<n:messageViewPrefix('id')>" ...>.
# Argumentos
# * codigo - Código de dicionário no formato 'modulo.view.id'.
# Retorno
# * Instrução refatorada.
function getColumni18n(codigo,   i, i18n, atag, id, acod) {
  if (!isarray(cot_atag)) {
    print "Erro: Deve ser chamado initColumn() antes desta função."
    return "";
  }
  cot_init();
 
  split(codigo, acod, ".")
  id = acod[length(acod)];
  gsub(/=.*/, "", id);

  for (i=1; i <= length(cot_atag); i++) {
    atag[i] = cot_atag[i];
    if (cot_atag[i] ~ "header=") {
      i++;
      atag[i] = sprintf("\"<n:messageViewPrefix('%s')>\"", id);
    }
  }
  for (i=0; i < length(cot_seps); i++) {
  i18n = i18n sprintf ("%s%s", atag[i], cot_seps[i]);
 }
 cot_end();
 return i18n;
}

# Retorna o código de dicionário no formato 'modulo.view.id'.
# Argumentos:
# * aMetaFile - Array com os metadados do arquivo.
# * id - Identificação exclusiva do texto em relação a view.
# Retorno:
# * Código de dicionário no formato 'modulo.view.id'.
function getColumnCod(aMetaFile, id) {
  cot_codigo = aMetaFile["module"] "." aMetaFile["file"] "." id;
  
  return cot_codigo;
}

# Retorna o código de dicionário com texto.
# Argumentos:
# * instrucao - Instrução contendo 'n:column ... header=...'.
# * aMetaFile - Array com os metadados do arquivo.
# * id - Identificação exclusiva do texto em relação a view.
# Retorno:
# * Código de dicionário no formato 'modulo.view.id=texto'.
function getColumCodComTexto(aMetaFile, id,    texto) {
  if (!isarray(cot_atag)) {
    print "Erro: Deve ser chamado initColumn() antes desta função."
    return "";
  }
  cot_init();
  
  if (!cot_codigo) {
    cot_codigo = getColumnCod(aMetaFile, id);
  }
  for (i in cot_atag) {
    if (cot_atag[i] ~ "header=") {
      texto = cot_atag[++i];
      gsub("\"", "", texto);
    }
  }
  cot_end();
  return cot_codigo "=" texto; 
}

# Salva parâmetros goblais.
function cot_init() {
  if ("sorted_in" in PROCINFO) {
    cot_save_sorted = PROCINFO["sorted_in"];
  }
  PROCINFO["sorted_in"] = "@ind_str_asc";
}

# Restabelece valores de variáveis goblais.
function cot_end() {
  if (cot_save_sorted) {
    PROCINFO["sorted_in"] = cot_save_sorted;
    cot_save_sorted = "";
  }
}
