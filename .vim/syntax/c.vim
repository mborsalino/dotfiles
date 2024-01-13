
syn keyword	cType		size_t off_t 

"; Python.h
syn keyword	cType		PyObject 

" mst custom data types
syn keyword	cType		chip_info_t chip_info_ptr udb_info_t udb_info_ptr  pdb_info_t pdb_info_ptr
syn keyword	cType		com_info_t com_info_ptr 
syn keyword	cType		u256_t 
syn keyword	cType		uint128_t int128_t __int128 __uint128 __int128_t __uint128_t

syn keyword	cType   bus_cont_t reg_cont_t	 	
syn keyword	cType		reg_def bitfield_def symname_def

syn keyword cType   uasm_symtab_t uasm_symtab_ptr
syn keyword cType   uasm_result_t uasm_result_ptr
syn keyword cType   pasm_result_t pasm_result_ptr
syn keyword cType   uasm_info_t uasm_info_ptr
syn keyword cType   pasm_info_t pasm_info_ptr

syn keyword cType   disasm_target_t disasm_target_ptr

syn keyword cType   udb_ctrl_ptr udb_ctrl_t udb_status_ptr udb_status_t
syn keyword cType   udb_state_t udb_state_ptr udb_func_args_ptr


syn keyword cType   pdb_pe_cfg_t pdb_pe_cfg_ptr
syn keyword cType   pdb_pe_bist_cfg_t pdb_pe_bist_cfg_ptr


syn keyword cType   ibkpt_t ibkpt_ptr dbkpt_t dbkpt_ptr ibkpt_scratch_t ibkpt_scratch_ptr

syn keyword cType   udb_exp_t

syn keyword cType   dbkpt_type_e 

syn keyword cType   com_handle_t com_handle_ptr 


syn keyword cType   pdb_tctrl_ptr pdb_tctrl_t pdb_tstatus_ptr pdb_tstatus_t
syn keyword cType   pdb_yld_status_t pdb_yld_status_ptr
" syn keyword cType   pdb_estate_t pdb_estate_ptr 

syn keyword cType   pdb_rtype_e
syn keyword cType   pdb_wint_t pdb_wint_ptr pdb_wint_sz_e
syn keyword cType   pdb_ibkpt_t pdb_ibkpt_ptr dbkpt_t dbkpt_ptr pdb_ibkpt_scratch_t pdb_ibkpt_scratch_ptr
syn keyword cType   pdb_ibkpt_head_t pdb_ibkpt_head_ptr

syn keyword cType   pasm_symtab_ptr scope_ptr scope_mode_t scope_mode_ptr

syn keyword cType   dict_ptr dict_node_t dict_node_ptr
syn keyword cType   mpsse_buf_info_t mpsse_buf_info_ptr


syn keyword cType byte
syn match cFunction "\<\([a-z][a-zA-Z0-9_]*\|[a-zA-Z_][a-zA-Z0-9_]*[a-z][a-zA-Z0-9_]*\)\> *("me=e-1
syn match Function "\$\<\([a-z][a-zA-Z0-9_]*\|[a-zA-Z_][a-zA-Z0-9_]*[a-z][a-zA-Z0-9_]*\)\> *[({]"me=e-1
syn match cType "\<[a-zA-Z_][a-zA-Z0-9_]*_[ft]\>"


" ----------------------------------------------- "
" ------------------- STELLAR ------------------- "
" ----------------------------------------------- "

" gmell.h
syn keyword cType   gmell_cluster_id_t
syn keyword cType   gmell_gme_id_t
syn keyword cType   gmell_forest_id_t
syn keyword cType   gmell_node_id_t
syn keyword cType   gmell_im_slot_t
syn keyword cType   gmell_operation_t
syn keyword cType   gmell_gmeinfo_t
syn keyword cType   gmell_clusterinfo_t

" gmell.c
syn keyword cType   gmell_cluster_t
syn keyword cType   gmell_gme_t
syn keyword cType   gmell_tle_entry_t
syn keyword cType   gmell_loc_t

" gmehal.h
syn keyword cType   gmehal_forest_tree_map_t

" gmehal.c
syn keyword cType   gmehal_chip_t
syn keyword cType   gmehal_cluster_t
syn keyword cType   gmehal_engine_t

" gmechip.h
syn keyword cType   gmechip_t gmechip_ptr gmechip_mem_e
syn keyword cType   gmechip_cl_cfg_t gmechip_eng_cfg_t

" gmechip.c
syn keyword cType   gmechip_op_e

" chashmw.c
syn keyword cType   chashmw_table_t

" gmesearch.h
syn keyword cType   gmesearch_search_t gmesearch_search_entry_t gmesearch_tree_stats_t

" ftl.h, pyftlmodule.c
syn keyword cType   tbit_t ftl_t pyftl_key_t 


