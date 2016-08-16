#! /bin/csh


# This is the script to create preprocessing scripts for the 
# palavras paradigm

set subjs = (SCHM002 SCHM007 SCHB010 SCHB012 SCHM015 SCHM021 SCHB025 SCHM033 SCHM034)

set run = FASTLOC



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

	afni_proc.py -subj_id ${subj} \
	-script proc.${subj}.${run}.NL.tcsh \
	-out_dir PROC.${run} \
	-dsets ${run}1/${subj}.${run}1.nii.gz  \
			${run}2/${subj}.${run}2.nii.gz			\
	#-blocks tshift align tlrc volreg blur mask regress \
	-do_block despike align tlrc                    \
	-copy_anat ANAT/${subj}.ANAT.nii.gz \
	#-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a \
	-volreg_align_to first  \
	-volreg_warp_dxyz 3 -volreg_tlrc_warp \
	#-tlrc_opts_at -init_xform AUTO_CENTER \
	-tshift_opts_ts -tpattern alt+z \
	#-anat_uniform_method unifize                    \
	-tlrc_base ${template} 				\
	-tlrc_NL_warp					\
	-align_opts_aea -skullstrip_opts 		\
		-shrink_fac_bot_lim 0.8 		\
		-no_pushout				\
		-giant_move				\
        -mask_segment_anat yes				\
	-blur_size 6 \
	-regress_stim_times ${script_folder}/timing/FASTLOC/times-afni_cond1.1D  \
	${script_folder}/timing/FASTLOC/times-afni_cond2.1D				\
	${script_folder}/timing/FASTLOC/times-afni_cond3.1D				\
	${script_folder}/timing/FASTLOC/times-afni_cond4.1D				\
	-regress_stim_labels c1 c2 c3 c4 \
	-regress_local_times \
	-regress_basis 'GAM' \
	-regress_reml_exec \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.9 \
	-regress_opts_3dD \
	-num_glt 12 \
	-gltsym 'SYM: +c1' -glt_label 1 'print' \
	-gltsym 'SYM: +c2' -glt_label 2 'speech' \
	-gltsym 'SYM: +c3' -glt_label 3 'false font' \
	-gltsym 'SYM: +c4' -glt_label 4 'vocod speech' \
	-gltsym 'SYM: +c1 -c3' -glt_label 5 'print-falsefont' \
	-gltsym 'SYM: +c2 -c4' -glt_label 6 'speech-vocod' \
	-gltsym 'SYM: +c1 -c2' -glt_label 7 'print-speech' \
	-gltsym 'SYM: +c3 -c4' -glt_label 8 'falsefont-vocod' \
	-gltsym 'SYM: +c1 +c2 -c3 -c4' -glt_label 9 'speech+print - falsefont+vocod' \
	-gltsym 'SYM: +c1 +c3 -c2 -c4' -glt_label 10 'print+falsefont - speech+vocod' \
	-gltsym 'SYM: +c1 -c2 -c3 +c4' -glt_label 11 'interaction' \
	-gltsym 'SYM: -c1 +c2' -glt_label 12 'speech-print' \
	-jobs 6 \
	-execute
	# compress brik files
	cd PROC.${run} 
	gzip -v *BRIK
end
exit

