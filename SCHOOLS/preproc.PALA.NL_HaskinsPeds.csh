#! /bin/csh


# This is the script to create preprocessing scripts for the 
# palavras paradigm

set subjs = (SCHM015)

set run = PALA



set script_folder = `pwd`
# get out of scripts folder
cd ..

set topdir = `pwd`

# updates:
#   - perform uniformity correction on anat before skull strip
#   - specify non-linear registration of anat to template --> will not do b/c of skull stripping issues
#   - censor outliers
# - doing a non linear registration to the HaskinsPeds mask

#set template = /media/DATA/IDEAL_BRAINS/nihpd_sym_07.5-13.5_t1w+tlrc
set template = HaskinsPeds_NL_template1.0+tlrc

foreach subj ($subjs)  

	cd ${topdir}
	cd ${subj}
	cd visit2

afni_proc.py \
	-subj_id ${subj}                       \
	-script proc.${subj}.${run}.NL.tcsh 	\
	-out_dir PROC.${run} 				\
	-dsets ${run}1/${subj}.${run}1.nii.gz	\
		${run}2/${subj}.${run}2.nii.gz	\
	-copy_anat ANAT/${subj}.ANAT.nii.gz	\
 	-do_block despike align tlrc  			\
	-tcat_remove_first_trs 3                        \
	-tshift_opts_ts -tpattern alt+z			\
	-volreg_align_to first				\
	-volreg_align_e2a				\
	-volreg_tlrc_warp				\
	-anat_uniform_method unifize                    \
	-tlrc_base ${template} 				\
	-tlrc_NL_warp					\
	-align_opts_aea -skullstrip_opts 		\
		-shrink_fac_bot_lim 0.8 		\
		-no_pushout				\
	-giant_move					\
        -mask_segment_anat yes				\
	-blur_filter -1blur_fwhm			\
	-blur_size 6 					\
    	-regress_stim_times ${script_folder}/timing/PALA/timing_PALA_reg.1D  \
	${script_folder}/timing/PALA/timing_PALA_ireg.1D 		\
	${script_folder}/timing/PALA/timing_PALA_pseudo.1D 		\
	${script_folder}/timing/PALA/timing_PALA_base.1D  		\
	-regress_stim_labels reg ireg pseudo base 			\
	-regress_basis_multi                            		\
		'BLOCK(7,1)' 'BLOCK(7,1)' 'BLOCK(7,1)' 'BLOCK(30,1)'    \
	-regress_opts_3dD                               	\
		-gltsym 'SYM: +reg -base'               	\
 		-glt_label 1 reg_vs_base                	\
		-gltsym 'SYM: +ireg -base'               	\
 		-glt_label 2 ireg_vs_base                	\
		-gltsym 'SYM: +pseudo -base'               	\
 		-glt_label 3 pseudo_vs_base                	\
		-gltsym 'SYM: +reg -ireg'               	\
 		-glt_label 4 reg_vs_ireg                	\
		-gltsym 'SYM: +reg -pseudo'               	\
 		-glt_label 5 reg_vs_psudo                	\
		-gltsym 'SYM: +ireg -pseudo'               	\
 		-glt_label 6 ireg_vs_psudo               	\
		-gltsym 'SYM: 0.5*reg 0.5*ireg -1.0*pseudo'    	\
 		-glt_label 7 reg+ireg_vs_pseudo                	\
		-jobs 6					\
        -regress_est_blur_epits				\
        -regress_est_blur_errts				\
        -regress_censor_motion 0.9                      \
   	-regress_censor_outliers 0.1                    \
	-regress_apply_mot_types demean			\
	-regress_run_clustsim yes			\
	-execute
	# compress brik files
	cd PROC.${run} 
	gzip -v *BRIK
end
exit

