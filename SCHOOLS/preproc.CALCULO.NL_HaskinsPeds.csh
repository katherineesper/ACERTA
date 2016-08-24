#! /bin/csh


# This is the script to create preprocessing scripts for the 
# senso numérico paradigm


set subjs = (SCHM034) 
set run = CALCULO


set script_folder = `pwd`
# get out of scripts folder 
cd ..

set topdir = `pwd`

# updates:
#   - perform uniformity correction on anat before skull strip
#   - specify non-linear registration of anat to template --> will not do b/c of skull stripping issues
#   - censor outliers
# - doing a non linear registration to the HaskinsPeds mask

set template = HaskinsPeds_NL_template1.0+tlrc




foreach subj ($subjs)  

	cd ${topdir}
	cd ${subj}
	cd visit2




afni_proc.py \
	-subj_id ${subj}                        \
	-script proc.${subj}.${run}.NL.tcsh 	\
	-out_dir PROC.${run} 				\
	-dsets ${run}/${subj}.${run}.nii.gz	\
	-copy_anat ANAT/${subj}.ANAT.nii.gz	\
 	-do_block despike align tlrc  			\
	-tcat_remove_first_trs 3                        \
	-tshift_opts_ts -tpattern alt+z			\
	-volreg_align_to first				\
	-volreg_align_e2a				\
	-volreg_tlrc_warp				\
	-anat_uniform_method unifize                                 	\
	-tlrc_base ${template} 				\
	-tlrc_NL_warp						\
	-align_opts_aea -skullstrip_opts 		\
		-shrink_fac_bot_lim 0.8 		\
		-no_pushout				\
        -mask_segment_anat yes				\
	-blur_filter -1blur_fwhm			\
	-blur_size 6 					\
    	-regress_stim_times ${script_folder}/timing/CALCULO/timing_equacao.1D  \
			    ${script_folder}/timing/CALCULO/timing_numeros.1D  \
	-regress_stim_labels eq num	 		\
	-regress_basis_multi                            \
		'BLOCK(5,1)' 'BLOCK(5,1)'		\
        -regress_censor_motion 0.9                      \
	-regress_opts_3dD                               \
		-gltsym 'SYM: +eq -num'               \
 		-glt_label 1 eq_vs_num                \
		-jobs 6					\
        -regress_est_blur_epits				\
        -regress_est_blur_errts				\
	-regress_apply_mot_types demean			\
	-regress_run_clustsim yes \
	-execute


	# compress brik files
	cd PROC.${run} 
	gzip -v *BRIK



end


exit





