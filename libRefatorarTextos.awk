# Arquivo: libRefatorarTextos.awk
# Descrição: Funções de refatorarTextos.awk

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
