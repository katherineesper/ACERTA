#! /bin/csh 

### In this script we will read the dicom files and convert them to NII. In the process we will also create the 
### subject folders as well as putting th nii files in the correct location. 
### Note, this script assumes that the subject folder exists, and inside it there is a "dicom" folder in it with the 
### dicom files in it
### 
### Author: Alexandre Franco
### Dez 17, 2013

### SOMENTE EDITAR ESTA PARTE PARA CADA SUJEITO@@@@@
set study = SCH
set subj = B037
set visit = visit1

set pala1 = 004
set pala2 = 005
set sennum = 008
set rst = 007
set anat = 007
set dti = 008

###########################@@@@@@@@@@@@@@@@@@@@
  
# get out of script folder
cd ..

# go inside subject folder
cd ${study}${subj}
cd ${visit}

# convert dicom images to nii
set subj_folder = `pwd`

if (0) then
	dcm2nii -c -g -o ${subj_folder} dicom/*
endif

##########################################################


# Palavras
if (1) then
	set image = PALA1
	set number = ${pala1}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	cd $subj_folder
endif
##########################################################


# Palavras
if (1) then
	set image = PALA2
	set number = ${pala2}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	cd $subj_folder
endif

##########################################################


# Senso Numérico
if (1) then
	set image = SENNUM
	set number = ${sennum}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	cd $subj_folder
endif
##########################################################


# Resting state
if (0) then
	set image = RST
	set number = ${rst}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	cd $subj_folder
endif

##########################################################


# T1 - Anatomical
if (1) then
	set image = ANAT
	set number = ${anat}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	cd $subj_folder
endif

##########################################################

# DTI
if (0) then
	set image = DTI
	set number = ${dti}
	mkdir ${image}
	cd ${image}
	mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.nii.gz
	mv ../2*s${number}*.bval ${study}${subj}.${image}.bval
	mv ../2*s${number}*.bvec ${study}${subj}.${image}.bvec
endif	

cd $subj_folder




if (1) then
# remove the rest of the junk that comes from dcm2nii
rm -v *nii.gz
endif


if (1) then
# Now we can compact the dicom folder
tar -zcvf dicom.tar.gz dicom

# Now we can delete the original dicom folder
rm -rfv dicom/
endif


exit












set mrs_ref_sag = 010
set mrs_ref_axial = 008
set mrs_ref_coronal = 009

set mrs_ga = 012
set mrs_br = 013


##########################################################
# MRS - Spectroscopia 
set image = MRS
mkdir ${image}
cd ${image}

#set mrs_ref_sag
set number = ${mrs_ref_sag}
set subname = REF_SAG
mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.${subname}.nii.gz


#set mrs_ref_axial
set number = ${mrs_ref_axial}
set subname = REF_AXI
mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.${subname}.nii.gz


#set mrs_ref_coronal 
set number = ${mrs_ref_coronal}
set subname = REF_COR
mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.${subname}.nii.gz

#set mrs_ga
set number = ${mrs_ga}
set subname = G_ANG
mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.${subname}.nii.gz
mv ../2*s2*${number}*.nii.gz ${study}${subj}.${image}.${subname}_SS.nii.gz

#set mrs_br
set number = ${mrs_br}
set subname = BROD
mv ../2*s${number}*.nii.gz ${study}${subj}.${image}.${subname}.nii.gz
mv ../2*s2*${number}*.nii.gz ${study}${subj}.${image}.${subname}_SS.nii.gz

cd $subj_folder















