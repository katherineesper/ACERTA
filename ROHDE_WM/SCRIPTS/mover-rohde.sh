#!/bin/sh
re='^[0-9]+$'
if [ "$1" == "-help" ]; then
echo "##################################################################"
echo "# Esse script cria uma pasta chamada AMBAC[ID_PACIENTE] dentro"
echo "# do projeto AMBAC e move as imagens baixadas pelo Pixsuite"
echo "# para dentro dela."
echo "# As imagens baixadas pelo Pixsuite ficam dentro do diretório do"
echo "# próprio programa e se chama Volume [ID_CRIADO_PELO_PIXSUITE]."
echo "# Exemplo de uso: mover-ambac [ID_PACIENTE] [ID_CRIADO_PELO_PIXSUITE]"
echo "## OBS 1: Os dois argumentos devem ser exclusivamente números!"
echo "## OBS 2: O [ID_CRIADO_PELO_PIXSUITE] deve existir e ser conferido"
echo "# no próprio software de acordo com o nome do paciente."
echo "##################################################################"
exit
fi
if [ -z $1 ] || [ -z $2 ]; then
echo "ERRO: Faltam argumentos!"
echo "-> Exemplo de uso: mover-ambac [ID_PACIENTE] [ID_CRIADO_PELO_PIXSUITE]"
echo "-> Digite mover-ambac -help para mais informações."
exit
elif ! [[ $1$2 =~ $re ]]; then
echo "ERRO: Os argumentos devem ser números!"
echo "-> Digite mover-ambac -help para mais informações."
exit
elif [[ ! -d "/media/DATA/Pixeon/pixsuite/downloads/record/Volume $2" ]]; then
echo "ERRO: A pasta [Volume $2] não existe!"
exit
else
mkdir -p /media/DATA/Rohde_WM/RWM$1/visit1/
mv "/media/DATA/Pixeon/pixsuite/downloads/record/Volume $2/" /media/DATA/Rohde_WM/RWM$1/visit1/dicom
echo "Concluído."
fi
