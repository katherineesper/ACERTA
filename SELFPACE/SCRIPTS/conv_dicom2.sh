#! /bin/csh 

set study = SELF
set subj = $1
set visit = 1
set volume_SELF = 300

# get out of script folder
cd ..
set project_dir = `pwd`

# go inside subject folder
cd ${study}${subj}
cd visit${visit}

#check if dicom directory exist inside project
if (! -d dicom ) then
echo
echo ---------------------------------------------------------------
echo "Não foi encontrado diretório dicom em ${study}${subj}/${visit}."
echo ---------------------------------------------------------------
exit
endif

# convert dicom images to nii
set subj_folder = `pwd`

	mcverter -f meta -x -a -u -o . dicom/
exit
	dcm2nii -c -g -o ${subj_folder} dicom/*



#Getting total number of series for each type
@ T_SELF1 = `find . -type d -iname '*self*_I_*' | wc -l`
@ T_SELF2 = `find . -type d -iname '*self*_II_*' | wc -l`
@ T_ANAT = `find . -type d -iname '*3d*' | wc -l`


#Getting the last serie number for each type
@ SELF1_LAST = `find . -type d -iname '*self*_I_*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | tail -n1`
@ SELF2_LAST = `find . -type d -iname '*self*_II_*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | tail -n1`
@ ANAT_LAST = `find . -type d -iname '*3d*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | tail -n1`

#####popup
echo "##########################################################################"
echo "O sujeito ${study}${subj} possui as seguintes séries:"
ls -d */ | grep -vwE "(dicom)" | sed 's:/$::'
echo "-----------------------------------------------------------"
printf "SELF1 possui $T_SELF1 imagem(ns) e a última realizada foi:	%03d\n" $SELF1_LAST
printf "SELF2 possui $T_SELF2 imagem(ns) e a última realizada foi:	%03d\n" $SELF2_LAST
printf "ANAT possui $T_ANAT imagem(ns) e a última realizada foi:	%03d\n" $ANAT_LAST
echo "-----------------------------------------------------------"
echo "A partir daqui o script começará a limpar os dados, removendo localiza-"
echo "dores, calibrações e as séries repetidas, mantendo apenas as que foram"
echo "especificadas acima. Verifique se estas informações batem com o scanlog."
echo "##########################################################################"
echo "Se você concorda com isso, digite s..."
set req = $<
if ( "$req" == "s"  ) then
	echo "Continuando..."
else
	exit
endif
echo

#removing junk files
echo "#################"
echo "Removendo lixo..."
echo "#################"

rm co*
rm o*
rm *_*_*/* #this remove everything inside mcverter folders

foreach serie_localizador ( `find -maxdepth 1 ! -iname '*SELF*' ! -iname '*3D*' ! -iname '*dicom*' -type d | sed 's:^./::' | cut -f 2 -d '_' | cut -f 1 -d '_' | tail -n +2` )
	echo Removendo serie ${serie_localizador}...
	rm -v *s${serie_localizador}a*
	rmdir -v *_${serie_localizador}_*/
end

#finding for duplicates series and removing it
echo "###############################"
echo "Procurando series duplicadas..."
echo "###############################"

if ( $T_SELF1 > 1 ) then
	echo "SELF1 tem mais de uma série."
	echo "Removendo as anteriores..."
	foreach i ( `find . -type d -iname '*SELF_I_*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | sed '$d'` )
  		find . -maxdepth 1 -type d -iname "*${i}*SELF_I_*" -exec rm -rv {} \;
	end
endif

if ( $T_ANAT > 1 ) then
	echo "Anat tem mais de uma série."
	echo "Removendo as anteriores..."
	foreach i ( `find . -type d -iname '*3d*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | sed '$d'` )
  		find . -maxdepth 1 -type d -iname "*${i}*3d*" -exec rm -rv {} \;
	end
endif

if ( $T_SELF2 > 1 ) then
	echo "SELF2 tem mais de uma série."
	echo "Removendo as anteriores..."
	foreach i ( `find . -type d -iname '*SELF_II_*' | cut -f 2 -d '_' | cut -f 1 -d '_' | sort -n | sed '$d'` )
  		find . -maxdepth 1 -iname "*${i}*SELF_II_" -exec rm -rv {} \; 
	end
endif

# rename nifti files and move to mcverter folders
echo "##########################################"
echo "Movendo as imagens para seus diretórios..."
echo "##########################################"

foreach x ( `ls *.nii.gz *.bv*` )
set serie_number = `echo $x | cut -f 2 -d 's' | cut -f 1 -d 'a'`
	if ( $x =~ *".nii.gz" ) then
		mv -v ${x} ${serie_number}.nii.gz
	endif

	foreach y ( `ls -d */ | grep -vwE "(dicom)" | sed 's:/$::'` )
		if ( ${y} =~ *_"$serie_number"_* ) then
			mv -v ${serie_number}* ${y}/
		endif
	end
end

#organize
echo "#########################"
echo "Fazendo ajustes finais..."
echo "#########################"

set SELF1 = `find . -maxdepth 1 -iname "dicom" -prune -o -print | egrep -io "(SELF)[[:punct:]](I)[[:punct:]]"`
set ANAT = `find . -maxdepth 1 -iname "dicom" -prune -o -print | egrep -io "(3D)"`
set SELF2 = `find . -maxdepth 1 -iname "dicom" -prune -o -print | egrep -io "(SELF)[[:punct:]](II)[[:punct:]]"`

foreach y ( `ls -d */ | grep -vwE "(dicom)" | sed 's:/$::'` )
	if ( $y =~ *"$SELF1"* && $SELF1_LAST > 0) then
		mv -v ${y}/ SELF1/
		cd SELF1
		mv *.nii.gz ${study}${subj}.SELF1.nii.gz
		cd ..
	endif
	if ( $y =~ *"$ANAT"* && $ANAT_LAST > 0) then
		mv -v ${y}/ ANAT/
		cd ANAT
		mv *.nii.gz ${study}${subj}.ANAT.nii.gz
		cd ..
	endif
	if ( $y =~ *"$SELF2"* && $SELF2_LAST > 0) then
		mv -v ${y}/ SELF2/
		cd SELF2
		mv *.nii.gz ${study}${subj}.SELF2.nii.gz
		cd ..
	endif
end

if (1) then
# Now we can compact the dicom folder
echo "################################"
echo "Compactando o diretório dicom..."
echo "################################"
echo
echo Aguarde...
echo
tar -zcf dicom.tar.gz dicom

# Now we can delete the original dicom folder
echo "##############################"
echo "Removendo o diretório dicom..."
echo "##############################"

rm *.nii.gz

echo "#######################################################"
echo "Removendo imagens nifti que possam ter ficado soltas..."
echo "#######################################################"

rm -rf dicom/
endif

echo
echo "##########"
echo "Concluído."
echo "##########"
echo
echo "############################"
echo "Verifique o resultado final:"
echo "############################"
echo

ls -R --hide=dicom.tar.gz

echo
echo "#######################################"
echo "Verifique se os volumes estão corretos:"
echo "#######################################"
echo

cd $project_dir
verificador ${volume_SELF} SELF1 ${visit} ${study}${subj}
verificador ${volume_SELF} SELF2 ${visit} ${study}${subj}

exit

