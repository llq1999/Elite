; Target assembler: acme v0.96.4 []
;*******************************************************************************
;* Elite for the Apple II                                                      *
;* Copyright 1985 David Braben and Ian Bell                                    *
;*                                                                             *
;*   ** THIS IS A WORK IN PROGRESS **                                          *
;*   (large sections of the code are uncommented)                              *
;*                                                                             *
;*******************************************************************************
;* This file was assembled from the two main game files and descrambled.  See  *
;* the 6502disassembly site for a full explanation.                            *
;*******************************************************************************
;* Disassembly by Andy McFadden, using 6502bench SourceGen v1.6.               *
;* Last updated 2020/03/18                                                     *
;*                                                                             *
;* The disassembly of the platform-neutral code is based heavily on the work   *
;* of others:                                                                  *
;*   Paul Brink's commented BBC Micro sources                                  *
;*   Kroc Camen's C64 project: https://github.com/Kroc/elite-harmless          *
;*                                                                             *
;* And of course thanks to Ian Bell for sharing the original BBC Micro         *
;* sources.                                                                    *
;*******************************************************************************
        !cpu    6502
EOR_FLIGHT =    $23        ;EOR value for flight text tokens
EOR_DOCKED =    $57        ;EOR value for docked text tokens
IWM_PH0_OFF =   $c080      ;IWM phase 0 off
IWM_MOTOR_OFF = $c088      ;IWM motor off
IWM_MOTOR_ON =  $c089      ;IWM motor on
IWM_DRIVE_1 =   $c08a      ;IWM select drive 1
IWM_Q6_OFF =    $c08c      ;IWM read
IWM_Q6_ON =     $c08d      ;IWM WP-sense
IWM_Q7_OFF =    $c08e      ;IWM WP-sense/read
IWM_Q7_ON =     $c08f      ;IWM write

rng_state =     $02
INWK    =       $0c
polyobj_xpos_lo = $0c
polyobj_ypos_lo = $0f
polyobj_zpos_lo = $12
polyobj_zpos_mi = $13
polyobj_zpos_hi = $14
polyobj_mox2_hi = $1a
polyobj_vertex_lo = $27
polyobj_roll =  $29
polyobj_pitch = $2a
polyobj_vis =   $2b
polyobj_attack = $2c
tmp_ptr2 =      $2d
text_hposn =    $34        ;text horizontal position (0-30)
text_vposn =    $36        ;text vertical position (0-23)
text_mod_flags = $37       ;$80=conv upper, $40=conv lower, $ff=discard
hull_ptr =      $5a
polyobj_ptr =   $5c
ecm_active_flag = $6a      ;initially $20, counts down
missile_thing = $7f
input_raw_key = $80        ;last key hit ($01-7f), or $00 if none
cmd_throttle_down = $81    ;bool 00/ff: throttle-down cmd
cmd_throttle_up = $82      ;bool 00/ff: throttle-up cmd
cmd_roll_left = $83        ;bool 00/ff: roll-left cmd
cmd_roll_right = $84       ;bool 00/ff: roll-right cmd
cmd_pitch_down = $85       ;bool 00/ff: pitch-down cmd
cmd_pitch_up =  $86        ;bool 00/ff: pitch-up cmd
cmd_fire_laser = $87       ;bool 00/ff: fire-laser cmd
cmd_energy_bomb = $88      ;bool 00/ff: energy bomb cmd
cmd_escape_cap = $89       ;bool 00/ff: escape capsule cmd
cmd_targ_mssl = $8a        ;bool 00/ff: target missile cmd
cmd_unarm_mssl = $8b       ;bool 00/ff: un-arm missile cmd
cmd_fire_mssl = $8c        ;bool 00/ff: fire missile
cmd_ecm =       $8d        ;bool 00/ff: ECM cmd
cmd_local_jump = $8e       ;bool 00/ff: local jump cmd
cmd_dock_on =   $8f        ;bool 00/ff: dock comp on cmd
cmd_dock_off =  $90        ;bool 00/ff: dock comp off cmd
player_speed =  $a9        ;player's current forward speed
displayed_screen = $b3     ;0 for space view, various for other screens
docked_flag =   $ba        ;bool 00/ff: are we currently docked?
display_mode_flag = $cd    ;bool (hi bit): showing text screen?
roll_velocity = $d1
pitch_velocity = $d2
BUFFER_0100 =   $0100
PLAYER_STATE =  $0241
computer_dock_flag = $026c ;bool 00/ff: is docking computer driving?
player_ecm_active = $026d
witch_space_flag = $026e   ;flag for witch space
main_dec2_thing = $0273
player_laser_temp = $0274  ;laser temperature
lcoord_swap_flag = $027d   ;bool 00/ff: did we swap start/end?
intro_parameter = $0284
player_credits = $0298     ;current credits, in big-endian order
player_fuel =   $029c      ;0-70
ship_state1 =   $029d
ship_state2 =   $029e
cargo_capacity = $02a5
player_cargo =  $02a6      ;items in player cargo bay
have_ecm =      $02b7      ;bool 00/ff: ship has ECM device
have_fuel_scoop = $02b8    ;bool 00/ff: ship has fuel scoop
have_energy_bomb = $02b9   ;00/7f/ff?
have_energy_unit = $02ba   ;bool 00/ff: ship has energy unit
have_docking_comp = $02bb  ;bool 00/ff: ship has docking computer
have_galactic_hyper = $02bc ;bool 00/ff: ship has galactic jump
have_escape_pod = $02bd    ;bool 00/ff: escape pod equipped?
kill_score_rem = $02c1     ;kill score remainder
missile_armed_flag = $02c2
player_fug_inno = $02c3    ;player fugitive / innocent status
kill_score =    $02d6      ;number of kills
in_flight_msg_token = $02dc ;flight token for briefly-shown messages
NMIVEC  =       $03fb
xcoords =       $0400
ycoords =       $0500
SCRNHOLE5 =     $06f8      ;text page 1 screen holes
data_buffer =   $0800      ;used for RWTS et.al.
KBD     =       $c000      ;R last key pressed + 128
KBDSTRB =       $c010      ;RW keyboard strobe
SPKR    =       $c030      ;RW toggle speaker
TXTCLR  =       $c050      ;RW display graphics
TXTSET  =       $c051      ;RW display text
MIXCLR  =       $c052      ;RW display full screen
TXTPAGE1 =      $c054      ;RW display page 1
HIRES   =       $c057      ;RW display hi-res graphics
BUTN0   =       $c061      ;R switch input 0 / open-apple
BUTN1   =       $c062      ;R switch input 1 / closed-apple
PADDL0  =       $c064      ;R analog input 0
PTRIG   =       $c070      ;RW analog input reset
ROMIN   =       $c081      ;RWx2 read ROM, write RAM bank 2
LCBANK1 =       $c08b      ;RWx2 read/write RAM bank 1

; 
; This is executed when ELA is BRUN.  It attempts to do an unnecessary (and
; possibly unsuccessful) copy of some data to the language card, and then exits.
; My guess is this is left over from a loader used during development that
; copied stuff into the LC, loaded everything else, then memory-moved the LC
; contents on top of DOS.
; 
; This area is used for data storage once the game starts.
; 
*       =       $0a00
        !zone   Z000000
.src_ptr =      $00
.dst_ptr =      $02
L0A00   lda     TXTPAGE1
        lda     MIXCLR
        lda     HIRES
        lda     TXTCLR
        lda     .src_ptr
        pha
        lda     .src_ptr+1
        pha
        lda     .dst_ptr
        pha
        lda     .dst_ptr+1
        pha
        lda     LCBANK1    ;read/write LC bank 1 -- not guaranteed to
        lda     #$00       ; write-enable since it's not touched twice
        sta     .src_ptr
        lda     #$40
        sta     .src_ptr+1
        lda     #$00
        sta     .dst_ptr
        lda     #$d0
        sta     .dst_ptr+1
        ldy     #$00
        ldx     #$30
@L0A2F  lda     (.src_ptr),y
        sta     (.dst_ptr),y
        iny
        bne     @L0A2F
        inc     .src_ptr+1
        inc     .dst_ptr+1
        dex
        bne     @L0A2F
        lda     ROMIN
        pla
        sta     .dst_ptr+1
        pla
        sta     .dst_ptr
        pla
        sta     .src_ptr+1
        pla
        sta     .src_ptr
        rts

        !hex    20204551555726443035303a4551555726
; Storage for disk access code.
rwts_track
        !byte   $44
rwts_sector
        !byte   $30
rwts_current_track
        !byte   $35
rwts_ts_track
        !byte   $30
rwts_ts_sector
        !byte   $3a
rwts_alloc_track
        !byte   $45
rwts_alloc_sector
        !byte   $51
rwts_delay_ctr
        !word   $5755
rwts_retry_2
        !byte   $26
rwts_retry_1
        !byte   $44
rwts_slot
        !byte   $30
rwts_find_slot_flag
        !byte   $35
rwts_saved_stack
        !byte   $30
rwts_addr_fields
        !byte   $3a
rwts_addr_sect
        !byte   $45
rwts_addr_track
        !byte   $51
        !hex    555726443035300d07df322e5343544248204551555726323032303a45515557
        !hex    26323132313a4551555726323232323a4551555726323332330d07e432202020
        !hex    202020204551555726323032303a4551555726323132313a4551555726323232
        !hex    323a4551555726323332330d07
; 
; Saved games are 110 bytes.
; 
; The file actually spans 114 bytes, because the first 4 bytes of the file are
; unused (would be the 'B' file header).  The next 106 bytes are scrambled with
; the RNG, and the last 4 bytes hold the RNG seed.
; 
; The code copies 76 bytes from +20 ($14-5F).
; 
scram_save_data
        !hex    e932202020202020204551555726323032303a4551555726323132313a455155
        !hex    5726323232323a4551555726323332330d07eb3c202020202020204551555726
        !hex    323032303a4551555726323032303a4551555726323032303a45515557263230
        !hex    32302020205c73616665
scram_rng_seed
        !hex    74790d07
        !hex    ee332e534354424832204551555726334333433a4551
; 
; A set of null-terminated strings that have been tokenized and EORed with $23
; (the $00 string terminators are not EORed).  Strings may recursively refer to
; other strings.
; 
; For example:
;  03 60 6b a9 77 00 --> 20 43 48 8a 54 --> "[$80] C H AR T"
; 
; See PrintFlightToken @ $7144 for an explanation of the mechanism.
; 
; Note there are two occurrences of $23 in the table, which become token $00
; (prints the cash balance).  This prevents us from trivially EORing the table
; to plaintext.
; 
flight_text
        !hex    4c32240003606ba97700646cb5716d6eb1770067b262322000afb56d77ba7a2f
        !hex    00707a70bf6e0073bda6002103a87168667703857000af67ab77bda3006264bd
        !hex    60766f7776b76f00bd606b030062b5b7a00300736cba0300a8af6f7a0300766d
        !hex    6a7700756a66740300b9b8b4777a00b8a9606b7a0065667667a3006e766fb40e
        !hex    8100ae6077b2ba9a00d86e766dbe770060bc65bbb362607a0067666e6c60b760
        !hex    7a0060ba73bab26603e8b26600706b6a730073dd677660770003b670b3006b76
        !hex    6eb803606c6fbc6aa3006b7a73b3707362a60300706bba7703e98200aee8b8a6
        !hex    00736c73766fb26abc0064dd707003996a756a777a006660bc6c6e7a00036f6a
        !hex    646b77037a66a97000bf606b0da2b56f006062706b0003a52c6abc0059822200
        !hex    77a9a077036f6ce800490369626e6ebb0071b8a00070770093036c6503007066
        !hex    2c000360a9646c250066b96a7300656c6c6700bf7bb46faa00b7ae6c6260b4b5
        !hex    700070b6b570006f6ab9ba0c74afaa006f767b76bdaa006da9606cb4607000d8
        !hex    737677b37000a8606bafb37a00626f6f6c7a7000656aada96e70006576717000
        !hex    6eafb3a37000646c6f6700736fb2af766e00a06e0ee8bcaa00a36ab1035c7000
        !hex    2f121323162300036071006fa9a000656ab3a60070a82c0064adb10071bb007a
        !hex    662c6c7400616f76660061b66068003500706f6a6e7a006176640e667abb006b
        !hex    ba6dbb0061bc7a0065b200657671717a00dd67b1770065dd64006f6aa7716700
        !hex    6f6c61e8b300a57167006b766eb86c6a670065666faf6600af706660770088b7
        !hex    aeab00606c6e00d86eb867b3000367aa77dd7abb00716c008d0303932f039903
        !hex    03038d03850365ba037062a22f29006571bc7700ada900a2657700bd646b7700
        !hex    5a6f6c7424004032df0200667b77b7030073766f70669800b0626e9800657666
        !hex    6f006ebe706aa200c0ed0361627a00660d600d6e0d860045447000454b70004a
        !hex    0370606c6c737000aa6062736603736c67005a616c6e61005a8d00676c6068af
        !hex    6403f40059039e006e6a6f6a77a97a0398006eafaf64039800e6192300afd8af
        !hex    64034900b1b3647a03006462b660b4600050036c6d00622c0026a264a303e8b2
        !hex    ab1900df03272f2f2f253c03862a212f9e862a202f60bcaeb4bc2a006abf6e00
        !hex    006f6f00b7b46d64190003bc03002f2bec6eb17719250060a2b8006c6565b167
        !hex    b3006576646ab4b5006ba96ea27070006e6ce86f7a0335008f00880062616cb5
        !hex    038800d8736677b1770067b8a0ddab00676662676f7a000e0e0e0e0366036f03
        !hex    6a03770366030e0e0e0e0073ad70b177002b64626e66036cb5710000
        !hex    0032373e   ;junk?
; 
; Table of sines.  The 32 entries are computed with:
; 
;   entry[i] = round(sin(i / 32.0 * PI) * 255)
; 
sine_table
        !hex    0019324a62798ea2b5c6d5e2edf5fbfffffffbf5ede2d5c6b5a28e79624a3219
; 
; A set of null-terminated tokenized strings used for messages while docked. 
; All of the data has been EORed with $57.
; 
; See PrintDockedStr @ $4b6e.
; 
docked_text
        !hex    575e5c565f77a6041c771614be0404771a12b6805d55667977c2806579770416
        !hex    ad77cd77538064797713121116021b0377561d161aba885580637977120f8c80
        !hex    57575714181a0712acac8877b61a15a36d57e73a9d39e6577777c277567f0e78
        !hex    197e68555b5b5707a5040477040716be77aa77111ea57bcd795b5b57cd70049f
        !hex    575b568bb210b377121b1e0312771e1e77111eb25740595510a58aa7100482e5
        !hex    441e77a010871a181aa10377181177e4057701b3028fb277ac1a129b00127700
        !hex    8e1b13771b1e1c1277e49e1318871b8c03b2771d18157711aa77bb9bc49877e4
        !hex    778d12771f12a59d16851a1813121b7b77c444148889051e1403aa7b7712a91e
        !hex    0793001eb587031807778d14058a85041f1e121b137710a1a3a2aa9b021911aa
        !hex    030219a2121b0e778c700477a0a17789181ba19b418c7700a103771a1e040494
        !hex    1105181a778e057798770eb91377887744b1a377111ead771a88b50477161018
        !hex    e54b9be405771a1e04041e887b77041f8e1b1377e4771312141e13129e1614be
        !hex    0703778c7b771e049e8d121ce513ba0305180e77c3989be47716a577141602ac
        !hex    8893b5a277881b0e775122520477008b1b7707a18aaf031277c419120077041f
        !hex    1e121b1304e5b5a277c444148889051e1403aa9d118c0393001eb577a877513b
        !hex    52e6555f10181813771b02141c7b77cd8341574e5e4059557777a203a1ac8882
        !hex    7977440012771f16ad77191293181177e405778d05011e14ba77161016a79b1e
        !hex    1177e477008e1b1377a077bc77101818137716049e10189e44bea3a677e47700
        !hex    8b1b77a07715051e1211ab9b1e1177040214be040411021b7b77e477008b1b77
        !hex    a07700121b1b77a500b913ab834f577f44147e9277666e6f6257150e925742c6
        !hex    9f4d574e5e4059557777148810af0302aeac880477cd765b5bb5a3125a77008b
        !hex    1b77b300160e0477a08707aebe7711aa77e477a7849ba81377b80ea077bc88a3
        !hex    77b5a877e477b5a71c7979834f57118fb21357b4038fb25700121b1b771cb400
        !hex    195711161a18bb57b403ab57ad050e571a8b131b0e571a188957a51604888f1b
        !hex    0e5757f257255710a5a2570116895707a71c57552077215a77ee16ac880457cb
        !hex    04572257d77711aaba03045718bea80457041f0e19ba0457048b1ba7ba0457b8
        !hex    039403afa6ac880457b7a21f941811773357b7ad7711aa773357111818137715
        !hex    b21913a30457038e051e89045707188a050e57a604141804573b5700b31c94c9
        !hex    5714af155715a257b71589574557a0048a5707ae1002ab57af011610ab571402
        !hex    0504ab5704148e0510ab572677141e018b7700b9573f77087737045716773f77
        !hex    a68d168d57267712b9b5a9161cba572677bcae05771614ac018c0e57f80a7709
        !hex    57c4467708773757f89604707735773457552d5a57f83c773b571d021ebe5715
        !hex    af19130e5700a2a35715a5005710b910b27715ae89a304574557467737574677
        !hex    455746773f573f774557118f02b7bb57120f18ac14571f1818070e5702b60402
        !hex    b357120f148ca7105714021e04a71257191e101f03771b1e1112571416041eb4
        !hex    0457048c7714181a0457552d5a575457c4c6775457c4c5775457c3c657c3c557
        !hex    048877181187158c141f5704148e1913a51b5715ae141c1002b9135705181002
        !hex    1257001faaba8877a08ab2771f1216139311ae077712b97013771c1916ad5719
        !hex    770219a5b8051c8fb2577715aaa710577713021b1b57770312a618bb5777a501
        !hex    181b03a71057c657c55707aebe571b8c03b277c65713021a07571e771f12b987
        !hex    2577b7181c94987716070712b993a286570e12161f7b771e771f12b987257798
        !hex    77b21103868777001f1eb2771516141c57108a77e405771e0588771604047718
        !hex    01a37703188657bc1a127724859877001604778da177a2865703050e86575757
        !hex    575700160407571a18b5571005021557a80357455707188a57b903047710af13
        !hex    02a212570e161c570419168b57041b021057030518071e14b35713a18d57afa7
        !hex    571e1a07a18aaf15b257120f02a0af190357110219190e5700121e05135702b6
        !hex    0402b35789af19b057071214021b1eb95711a5a9a1035718141416041e88b357
        !hex    021907a5a614038fb25713a5161311021b57fc570b770c7711aa773257dbe532
        !hex    573177150e773057db7715020377d957771638772757071ba88a5700aa1b1357
        !hex    b5127757b51e047757b7161385cd575e5c565f5713051ead577714a216b71002
        !hex    12571ea8574414181a1aa813a3573f571a8e190316a757ab1e15b25703a51257
        !hex    0407180303ab572f572e5736181e135728572957a8141ea10357120fbe07ac88
        !hex    b3571214be1903051e1457a710afa7ab5725571c8b1ba357131216131b0e5712
        !hex    018b57b2b5b357011e141e18bb578c0477575a594457795b585777a81377570e
        !hex    8e5707b91c941a8aa3045713bb037714b7021304571ebe77a005100457051814
        !hex    1c7711aab8ac88045701181b1416b4ba57071ba8035703021b1e075715a8a816
        !hex    5714aa1957450012ab5745574677455746773f57a71f16bd03a80357e857a710
        !hex    7757ab775777137915afa0197771771e79a01b1b5757577719161a1268775777
        !hex    03187757771e04775700160477ae89778da177a2774457795b7744571318141c
        !hex    ab57567f0e78197e6857041f1e07577716775777a3051ebb5777191200775755
        !hex    771fa377b81dba030e700477040716be771916010e5a57e65f5677771aba0416
        !hex    b077a113045777cd77537b771e775a161a55771416070316a7774c775a181184
        !hex    5757587702191cb4001977c6575e5f405677a714181a941aba0416b057140205
        !hex    0502b5a30457111804130e1c1277041a0eb5125711aa03baa912579ca5baa6be
        !hex    571e0477a01b1e1201ab9e1f16ad771d021a07ab9ec310b3160f0e574e5e4a59
        !hex    55101818137713160e77cd77539b1e5a77161a77441610a103774415ae1c1277
        !hex    18117744191601b37744a703121bb210a1be9b160477e4771cb4007b77c44419
        !hex    16010e771f16ad77a0a1771c12120794c444b5b910181e13047718111177e405
        !hex    77160404778e0377a7771312120777040716be7711aa77b8190e770e12b90477
        !hex    b40079774400121b1b77c4048c0216ac88771f160477141fa810ab9b8e057715
        !hex    180e0477b91277a516130e7711aa870702041f77051e101f039ec41f181a1277
        !hex    040e0403121a77181177b5188d771a020513a3a3049b4f5e4a1e5a771f16ad77
        !hex    18150316a793c4131211a1be7707ae19047711aa77b5121e0577441f1ead7744
        !hex    00aa1b13049bc4a08ab204771cb40077001270ad7710180377bc1a12b5941502
        !hex    0377b40377001fa29b1e1177441e7703af19041a8c77c407ae19049e8e057715
        !hex    168d77887744bda5af77b5120e701b1b77a703a3be070377c40305a8041a1e04
        !hex    041e887977441e771912ab87989eb81c1277c40502199be470a57712b21403ab
        !hex    9bc407ae19047716a57702191e07021b8d7714181393001eb5a777c30305a804
        !hex    1a1e04041e889b5fe477008b1b77a07707161e139b777777774410181813771b
        !hex    02141c77cd834f574e5e4a5f595a4400121b1b7713881277cd9be4771f16ad77
        !hex    8d05019302047700121b1be5001277041fb31b77a51a121a15a39b001277131e
        !hex    1377b40377120f0712140377c444b5b910181e13049e11a713778e037716158e
        !hex    0377e49b11aa77c41a181aa1037707b2168d771614be070377c3441916010e77
        !hex    5125527716047707160e1aa103834f5716a577e4770402a56857041fa50057a0
        !hex    168957151e0488570419161c125700181b1157b21807b9135714a2571a881c12
        !hex    0e571018a257111e041f573d773e5746772f772c57f83c772e772c572b772a57
        !hex    3d773e571a12a2571402031b8a578912161c5715020510a30457bc0207571ebe
        !hex    571a0213570da3187a44105701161402021a574677021b03af571f18141c120e
        !hex    5714051e141c8a571cb9a212570718b75703a1191e04575b4977a305aa57
text_stuff1
        !hex    d396241cfd4f3576642044a4dc6a10a2036b1ac0b80565c129
text_stuff2
        !hex    018000000001010101820101010101010101010101010102018290
; 
; More strings in "docked" format.  Index 0-26.
; 
ext_docked_text
        !hex    57c41418b7191e8904771f12a5771f16ad77011e181ba2ab5577a703a310b316
        !hex    14ac147714b71994070518031814181b5ae5041f8e1b1377a0771601181e13ab
        !hex    57c4148889051e1403aa779ca5baa6be7b77cd5716772577b7181c949877b211
        !hex    03771f12a587001f1eb2771516141c79771b18181c93158e19137711aa77b912
        !hex    b1570e12077b87258598771f16138710b31614ac14771f0e07a313051ead7711
        !hex    8c03931f12a57977bb938c7703181857c3772577987713121f0e07931f12a577
        !hex    1105181a77b4001f12a57b7704021977041c1e1a1aabe51d021a07ab79771e77
        !hex    1f12b9778c7700a1039ea7bda0572477987700a1037711aa771a1277a27716bb
        !hex    b979771a0e77ae04a30477131e13197003771201a1770414af03141f77c42457
        !hex    181f771312b9771a12770eba798711051e101f0311021b77051810021277001e
        !hex    b577001fa2771e77a01b1e12ad77e47707121807b27714b31b87b21613770718
        !hex    89a31eaa77041f180377020777b7030477181177b5188d77a016891b0e77071e
        !hex    af03bae500a1039ebbb2051e57e47714a8770316141cb277c43f7724771e1177
        !hex    e4771b1e1c1279771f12700477a277aab9af575614181a94bc886d77121b8c12
        !hex    771e1e5723572357235723572357235723572357235723572357235723571518
        !hex    0e7716a577e477a777c4000588107710b3160f0e7657b5a312700487a5b37724
        !hex    77071eaf0312778e0377b5a31257c49604771811773a7716a577bc7716b80da7
        !hex    101b0e7707051e1a1eacad77b5a277b5120e77898b1b77b5a71c77447d7d7d7d
        !hex    7d777d7d7d7d7d7d9d776413575600121b14181a129e77c48dad190312a1b577
        !hex    1016ae0f0e7657
        !text   ".Tribbl"  ;trouble?
font_glyphs
        !hex    00000000000000003838383800380000363624120000000080247e247e248000
        !hex    083e023e203e080042251208245221000c1602042a122c001818100800000000
        !hex    381c0e0e0e1c38000e1c3838381c0e00221c361c220000000008083e08080000
        !hex    00000000181810080000007e7e00000000000000181800006070381c0e060000
        !hex    1e333b3f37331e000c0e0f0c0c0c3f001e3330180c063f001e33301c30331e00
        !hex    383c36333f3030003f03031f30331e001c06031f33331e003f33180c0c0c0c00
        !hex    1e33331e33331e001e33333e30180c0000181800181800000018180018181008
        !hex    10181c1e1c18100000007e007e000000040c1c3c1c0c04003c7e623018001800
        !hex    9088b6ffffffbeb61e33333f333333001f33331f33331f001e33030303331e00
        !hex    0f1b3333331b0f001e33031f03331e001e33031f030303001e33033b33331e00
        !hex    3333333f333333003f0c0c0c0c0c3f003030303033331e00331b0f070f1b3300
        !hex    0303030303033f00333f3333333333003333373b333333001e33333333331e00
        !hex    1f33331f030303001e3333373b331e001f33331f0f1b33001e33031e30331e00
        !hex    3f0c0c0c0c0c0c003333333333331e0033333333331e0c0033333333333f3300
        !hex    33331e0c1e3333003333331e0c0c0c003f30180c06033f001e1e06061e1e0000
        !hex    060e1c38706000007878606078780000081c3e7f000000000000000000007f00
        !hex    181808100000000000001e303e333e0003031f3333331f0000001e3303331e00
        !hex    30303e3333333e0000001e333f031e001c36061f0606060000001e33333e301e
        !hex    03031f33333333000c000c0c0c0c0c00300030303030331e0303331b0f1b3300
        !hex    0c0c0c0c0c0c0c0000003e6b6b63630000001e333333330000001e3333331e00
        !hex    00001e33331f030300001e33333e303000001e330303030000003e031e301f00
        !hex    06061f0606361c000000333333331e0000003333331e0c00000063636b6b3e00
        !hex    0000331e0c1e330000003333333e301e00003f180c063f00f098989c9898f080
        !hex    18181818181818180e18183818180e0000000000000000000000000000000000
; 
; The title screen remains for the entire game -- only the viewport is erased.
; 
title_screen
        !hex    c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aa0000c080808080d5aaf7eeddbbd4aad5aad5aac5aad5a2d5aad5
        !hex    aad5aaf6eeddabd5aa95808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa80000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c08080808080aaf7eeddbb90888480808080aad580808080
        !hex    a09088f6eeddbbd7aa85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c080808080808080a08580d08085a881a0c582d0a281a085a0d180d0a8818080
        !hex    8080808080a08000c0808080808080d5eaddbb8482d9bbf7eedda895eeddbbf7
        !hex    8ec1a0f6eeddabd58280808080a08000c0000000000000008100000000000000
        !hex    000000000000000000000088000090000004000000a000000000000000000000
        !hex    c080808080808080f0818bf8c085bcc1f0e78af9b38570c5809e8af8ac818280
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad0aad5aa95a8d5a0d5aa
        !hex    d582d4aad5aad5aad5aad5aad5aa8000c0000000000000008100000088000084
        !hex    200000810004a000008400a0000094000004000000a000000000000000000000
        !hex    c0808080808082d4aad5aaf5aad5abd7ead5bad5aad5aad7aaddaaf5aad5aac1
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa00a0d080c080c080c0a08180
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c0000000000000008100000000008200
        !hex    00000081000000c000000000820090000000000000a000000000000000000000
        !hex    c08080c0aaddbbd7eeddbaf7eedd8bf0eeddbbf7eedd83f0eeddbbf7eeddbbd5
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad0a0d4a8c182c080c0a8d182
        !hex    8588d4aad5aad5aad5aad5aad5aa8000c0000000000000008184000000810000
        !hex    000000810000000000810000a00090000000000015a000000000000000000000
        !hex    c0808080a0d5bbf7eeddbbc7a0c482c58ac4bbf7a2d0a2c1a284b2f7eeddabf7
        !hex    ae85808080a08000c0aad5aad5aad5aad5aad5aad1a2d4a8d1a2c488d1a2c58a
        !hex    95a2c4aad5aad5aad5aad5aad5aa8000c000000000000000810000c100000000
        !hex    000000810000000000008281000090000000000015a000000000000000000000
        !hex    c0808080aad5bbf7eedd83c4aad5aad5aa91808188d5aad5aad5a2e0eeddbbf7
        !hex    aad5808080a08000c0aad5aad5aad5aad5aad58a91aad488d1a2c488d1a2d588
        !hex    d5a2d5a8d5aad5aad5aad5aad5aa8000c0000000000000008100000000000000
        !hex    000000000000000000000000000090000000000001a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080d5aad5baf7ae808080808080c0aad582808080
        !hex    808080dcbbf7aeddabd5808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa80000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080c0aaddbbf7ae948ae5eeddbb97aad5b8f7eedd
        !hex    a3d1a8dcbbf7eeddaa81808080a08000c000000000000000c100000000000000
        !hex    00000000000000000000008884a490000000000000a000000000000000000000
        !hex    c080808080808080a08180d08085a881a0858ad08285a085a0d180d0a8818080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aaa5a5d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0285100000000008100000000000000
        !hex    000000000000000000000088000090000000000000a000000000000000000000
        !hex    c080808080808080f0818ff8f3c7fcdff0e1a3f9f081f8c780988ff8fc878280
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa85aad08ad48ad48ad4a095a8
        !hex    d5a2d4aad5aad5aad5aad5aad5aa8000c0d0888100000000810000c082000000
        !hex    000000000000000000c082a000859400000000c082a400000000000000000000
        !hex    c080808080c0aad4abd5aeddabf5eaddaad7eeddaad7eaddaad5aaddaad7aa95
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa00a0d080d080c080c0a081a0
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c0d0a881000000008190000000000000
        !hex    000008100000000000000000880090000000000004a000000000000000000000
        !hex    c08080c0aaf5eeddbaf7eaddbbf78ec180f7eeddbb818299bbf7eed5bbf7eed5
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c090a881000000008190000000000000
        !hex    000000000000000000000000880090000000000010a000000000000000000000
        !hex    c0808080a8d5eeddbbf7eec5a2c4a2c58ae4eedda3d0a2c5a2c4e2ddbbf7eadd
        !hex    ab81808080a08000c0aad5aad5aad5aad5aad5aac5a8d1a2c588d1a2c4a8d1aa
        !hex    c588d1aad5aad5aad5aad5aad5aa8000c0d0a200000000008100009400000000
        !hex    000000000000000000008800000090000000000010a000000000000000000000
        !hex    c0808080aad5eeddbbf7a2c4aad5aad5aa90a2c588d4aad5aad5a2c4bbf7eedd
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad58ad5aac4aad5aad58ad5aa
        !hex    d4a8d5a2d5aad5aad5aad5aad5aa8000c0000000000000008100000000000000
        !hex    204500512205000000000000000090000000000011a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080d5aaf5eaddbbf7eeddbbf7eec5aad5e2ddbbf7
        !hex    eeddbbf7eeddbbf7aad5808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa80000000000000000000
        !hex    c080808080808080808080800000800080808080000080808080808000008080
        !hex    8080808080a08000c080808080c0aaf5eeddbb948ac5bbf7ee9daad5ecddbbf7
        !hex    a2d1a8f6eeddbbd5aa80808080a08000c0285100000000009100000000000000
        !hex    00000000000000000000008881009100000000c0a2a500000000000000000000
        !hex    c080808080808080a08180d08085a881a09588d08a84a085a0d18290aa818080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aaa5a5d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0081100000000008100000000000000
        !hex    000000000000000000000088a2909200000000c082a100000000000000000000
        !hex    c080808080808080f0e78cf8f3c7fcfff2f9a3fdfc81f8d7f0818ff9f0c78280
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa85aad58ad48ad48ad4aa95a8
        !hex    d5aad4aad5aad5aad5aad5aad5aa8000c0908881000000008100009000000081
        !hex    0000008100000081000088a081009100000000c088a100000000000000000000
        !hex    c080808080d4aad5aed5bbf5aaddbbf7eaddbbd7eeddaaf7aaddabf7eaddaa95
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa80a0d080d4a0d5a0c1a081a8
        !hex    c188d4aad5aad5aad5aad5aad5aa8000c090a000000000008190000000c00000
        !hex    000000810000000082000000880090000000000005a000000000000000000000
        !hex    c0808080aad5bbd7eeddbbf7ee9d80e5c8ddbbf7ee91a381ecc1bbf7eeddbbd5
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c090a0000000000081900000a0000000
        !hex    000000810000000000840000880090000000000015a000000000000000000000
        !hex    c0808080aad5baf7eeddbbc7a2c4a2c58ac5bbf7a2d1a2c5a2c4b2f7eeddbbf7
        !hex    aa81808080a08000c0aad5aad5aad5aad5aad5aad1aad4a8d1a2c4a8d1a2c58a
        !hex    95a2c4aad5aad5aad5aad5aad5aa8000c090a20000000000810000c000000000
        !hex    000000810000000000c08200000090000000000015a000000000000000000000
        !hex    c0808080aad5bbf7eedda3d4aad5aad5aa94a2c5a8d4aad5aad5aae4eeddbbf7
        !hex    aa85808080a08000c0aad5aad5aad5aad5aad5aad5a2d4aad1aad5a8d1a2d4aa
        !hex    d1a2c4a8d5aad5aad5aad5aad5aa8000c0307e00000000008100000000000000
        !hex    204000412000000000000000000090000000000011a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080d5aaddabf7eeddbbf7eeddbb87aad5b0f7eedd
        !hex    bbf7eeddbbf7eeddaad5808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c08080808080808080d08280aa80a080a08180d08080808180d482c080818080
        !hex    8080808080a08000c08080808080aaddbbf7ae8482e1eeddbb97aad5b8f7eedd
        !hex    83c1a0dcbbf7aed58a80808080a08000c0081000000000008500000000000000
        !hex    0000000000000000000000a800859500000000c0a0a400000000000000000000
        !hex    c080808080808080a08180d08085a881a09588d08a84a085a0c18290aa808080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aaa5a5d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0085100000000008100000000000000
        !hex    00000000000000000000008800009000000000c088a100000000000000000000
        !hex    c080808080808080c0ff8cf97fc7fcfff2f9a3fdfc81f8d7f2818ff9f3c78280
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa80a0c080c080c080c0808180
        !hex    8180d4aad5aad5aad5aad5aad5aa8000c0d088810000000081000085a2c48891
        !hex    a2c48890a2c48890a2c4a08181859100000000c088a100000000000000000000
        !hex    c080808080d5aad5bbd5eeddabf7eeddaad7eeddbaf7eeddabf5aeddbbd7ae95
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aac0aad080d0a0d5a0c1a081a0
        !hex    c188d4aad5aad5aad5aad5aad5aa8000c090a000000000008184000000000000
        !hex    000000000000000000000000a00090000000000004a000000000000000000000
        !hex    c0808080aad5eeddbaf7eedd8396828588f7eeddbb91a0c1b8e0eeddbbf7eed5
        !hex    aad5808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c090a0000000000081c0000000000000
        !hex    0000000000000000000000008a0090000000000001a000000000000000000000
        !hex    c08080c0aad5eaddbbf7aec0a2c4a2d58ae5eedda3d1aac5a2c482dcbbf7eedd
        !hex    aa81808080a08000c0aad5aad5aad5aad5aad5aac4aad1a2d5a8d5a2c5a8d1aa
        !hex    c4aa95aad5aad5aad5aad5aad5aa8000c0d0a2000000000081000000a8000000
        !hex    000000000000000000940000000090000000000010a000000000000000000000
        !hex    c0808080a8d5eeddbbf7a2d5aad5aad5aac5a2c5a2d5aad5aad5aac5bbf7eedd
        !hex    ab85808080a08000c0aad5aad5aad5aad5aad5a2c48a91a2d488d1a2c48a95a2
        !hex    d48a91a2d5aad5aad5aad5aad5aa8000c0d0aa81000000008100000000000000
        !hex    204100412001000000000000000090000000000015a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080d4aaf7eeddbbf7eeddbbf7ee9daad5ecddbbf7
        !hex    eeddbbf7eeddbbf7aa95808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c08080808080808080d482c0aa81a881a09180d08880808180d582d0a2858080
        !hex    8080808080a08000c08080808080aaf5eeddbb8482d9bbf7ee9daad5ecddbbf7
        !hex    8ec1a0f6eeddabd58a80808080a08000c0285100000000008100000000000000
        !hex    0000000000000000000000a800009400000000c0a2a400000000000000000000
        !hex    c080808080808080a0c182d08085a881a09588d08a84a085a0c58a9088808080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aaa5a5d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c02841000000000081000000000000c0
        !hex    a8c4a295a29182000000008800009000000000c08aa100000000000000000000
        !hex    c080808080808080c09f83e5ffd1fefff299a8fd8c80cad1c2ff83f9f3d78a80
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa00a0c080c080c080c0808180
        !hex    8180d4aad5aad5aad5aad5aad5aa8000c0908881000000008100a0000000a000
        !hex    00000081000000840000008485a09000000000c088a100000000000000000000
        !hex    c0808080aad5aad5eed5bbf7eaddbbf7eeddbaf7eaddbbf7aeddabf7eaddab85
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aac0aad0a0d0a0d5a0c1a0c1a0
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c090a0000000000081c48891a2c48891
        !hex    a2c4c890a2c48891a2c48891820090000000000004a000000000000000000000
        !hex    c0808080a8d5bbf7eaddbbf7a29c8285caddbbf7eed1a0c1acc4bbf7eeddbbd5
        !hex    aad5808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c090a0000000000081c0000088000000
        !hex    000000810000000000900000820090000000000015a000000000000000000000
        !hex    c08080c0aad5aaf7eeddbbc4a2c4aad58a85b897a0d1aad5a2c4a2f6eeddbbf7
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad1aad4a8d1a2c5a8d1a2c58a
        !hex    95aac5aad5aad5aad5aad5aad5aa8000c090a200000000008100000000850000
        !hex    0000008100000000a8000000000090000000000015a000000000000000000000
        !hex    c0808080a8d5bbf7eedd83d5aad5aad5aac5a895a2d5aad5aad5aae1eeddbbf7
        !hex    aa85808080a08000c0aad5aad5aad5aad5aad588d1a2d488d5a2c488d1a2d488
        !hex    d1a2c4a8d5aad5aad5aad5aad5aa8000c090aa00000000008500000000000000
        !hex    204000412000000000000000000094000000000010a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080d0aaddbbf7ee81808080808080a08580808080
        !hex    8080c0ddbbf7eeddaa85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c08080808080808080d58ad0aa85a881a0d180d0a880a08580958ad0a2858080
        !hex    8080808080a08000c08080808080a8d5bbf7ae8482f1eeddbb97aad5b8f7eedd
        !hex    8bc1a0dcbbf7aed58a80808080a08000c0084000000000008100000000000000
        !hex    0000000000000000000000a80085940000000000a2a500000000000000000000
        !hex    c080808080808080b0d18ad88085ac81f09588f88a84b08580858a98aa808080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aa95a9d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0085100000000008100000000000085
        !hex    02000000004088850000008800859000000400c082a100000000000000000000
        !hex    c080808080808080809fa395bfd5fadfc281aae5a8c1ead582fea3e5c0d18a80
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aa00a0c080c080c080c0808180
        !hex    8180d4aad5aad5aad5aad5aad5aa8000c090a000000000008100880000000000
        !hex    000000000000000000000090d4aa9500000400c082a400000000000000000000
        !hex    c0808080aaf5aad5bad5eeddbbf7eeddbbd7eeddbaf7eeddbbf5aeddbbd7aed5
        !hex    8084808080a08000c0aad5aad5aad5aad5aad5aac0aad0a0d0a0c5a0c1a0c1a0
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c0d0a000000000008100000000000000
        !hex    000090830000000000000000a00090000000000015a000000000000000000000
        !hex    c0808080a0d5eeddbaf7eedda3968a858af7eeddbbd1a0d1b0e4eeddbbf7aed5
        !hex    aa95808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0d0a0000000000081008a0000000000
        !hex    0000000000000000000000c0000090000000000000a000000000000000000000
        !hex    c08080c0aaf5aeddbbf7aec4a2d5aad5aa85ec9da0d5aad5aac5a2dcbbf7eedd
        !hex    abd5828080a08000c0aad5aad5aad5aad5aad5aad48ad5aad4a8d5a2c5a8d5aa
        !hex    d48895aad5aad5aad5aad5aad5aa8000c090a281000000008100000000c08200
        !hex    00000000000000d000000000000090000000000000a000000000000000000000
        !hex    c0808080a0d5eeddbbf78ed5aad5aad5aad1a8958ad5aad5aad5aad9bbf7eedd
        !hex    aa81808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5a2d5aad5aad5aad5aad5aa8000c0900000000000009100000000000000
        !hex    20450a412005000000000000000091000000000000a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c080808080c0aaf7eeddbbd1aad5aad5aad582c1aad5aad5
        !hex    aad58af7eeddbbf7aa85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c08080808080808080958ad0a285a881a0d180d0a880a08580818ad0a0858080
        !hex    8080808080a08000c08080808080a0d5eeddbb8482d9bbf7ee9da895ecddbbf7
        !hex    8ec1a0f6eeddabd58a80808080a08000c0085000000000008100000000000000
        !hex    0000000000000000000000a800009044081122c0a2a000000000000000000000
        !hex    c080808080808080b0c18ad88085ac81f09588f88a84b08580958a98aa818080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aa95a9d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0000000000000008100000000908a90
        !hex    00000081000088c08200008800009000224408c088a500000000000000000000
        !hex    c080808080808000a095a8d5aad5aad58ac0aad5aad5aad582d5a0d5aaddaa80
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad0aac5aad5a0d1a0d58a
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c0000010080402418100820000008800
        !hex    0040008102000090000000c0000090002244080000a000000000000000000000
        !hex    c08080c0aaddabd5eeddbaf7eeddbbf7eeddbbd7eeddbbf7aeddbbf5eeddbbd5
        !hex    8285808080a08000c0aad5aad5aad5aad5aad5aac0aad0a0c180c0a0c1a0c182
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c0000010204000018184000000840000
        !hex    0000600f00000000a0000000000090000000000000a000000000000000000000
        !hex    c080808080d5bbf7eeddbbf7a2808a85caddbbf7eed1a0d180c4bbf7eeddabd5
        !hex    ae85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c00000100804020181008891a2c48891
        !hex    a2c48891a2c48891a2c48891000090000000000000a000000000000000000000
        !hex    c0808080aad5bbf7eeddbbc4a2d5aad5aac1889082d5aad5aac5a2f6eeddbbf7
        !hex    aad5828080a08000c0aad5aad5aad5aad5aad58ad1aad4a8d1a2d5a8d1a2c588
        !hex    95aac4a8d5aad5aad5aad5aad5aa8000c000001008102000810000000000a091
        !hex    000000810000a28100000000000090000000000000a000000000000000000000
        !hex    c080808080d5bbf7eedd8bd4aad5aad5aad1aad58ad5aad5aad5aaf0eeddbad7
        !hex    aa81808080a08000c0aad5aad5aad5aad5aad58ad5a2d5a2d5aad48ad58ad58a
        !hex    d5aad588d5aad5aad5aad5aad5aa8000c000000000000000c100000000000000
        !hex    00000000000000000000000000a090000000000000a000000000000000000000
        !hex    c080808080808080808080808080808080808080808080808080808080808080
        !hex    8080808080a08000c08080808080aaddbbf7eed1aad5aad5aad5aad5aad5aad5
        !hex    aad5caddbbf7eeddaa85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000
        !hex    c080808080808080a08588d0a285a881a0d182d0a881a085a09188d0a8858080
        !hex    8080808080a08000c08080808080a0d5baf7ae8482f1eeddbbf7a895bbf7eedd
        !hex    8bc1a0dcbbf7aad58280808080a08000c00000502a552a558100000000000000
        !hex    000000000000000000000088008590552a552a0500a000000000000000000000
        !hex    c080808080808080b0818bd8c085bc81f09f8af88f8570c5809e8af8ac818080
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aa95a9d5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c00000502a552a558100000000850000
        !hex    0000000000000000a08100a8008590552a552a0500a000000000000000000000
        !hex    c0808080808080d4aad5aed5aaf5aaddaad5aad5aad5ead58ad5aaddaad7aa81
        !hex    8080808080a08000c0aad5aad5aad5aad5aad5aad5aad0aac5aad5a0d1a0d58a
        !hex    c18ad4aad5aad5aad5aad5aad5aa8000c00000502a552a5581c0000000000000
        !hex    000000000000000000000000820090552a552a0500a000000000000000000000
        !hex    c08080d0aaf7aed5baf7eaddbbf7aedcbbd7eeddbbf7eeddbbf7eed5bbf7aed5
        !hex    aa85808080a08000c0aad5aad5aad5aad5aad5aac0a0d4a0c180c0a0c1a8c182
        !hex    8100d4aad5aad5aad5aad5aad5aa8000c00000502a552a558100000000000000
        !hex    000000000000000000000000a00090552a552a0500a000000000000000000000
        !hex    c080808080d5eeddbbf7ee85a0c08ac58ae0eedd83d0a2d18284e0ddbbf7aed5
        !hex    ab85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c00000502a552a558100a00000000000
        !hex    000000000000000000000084000090552a552a0500a000000000000000000000
        !hex    c0808080aad5eeddbbf7aec4a2d5aad5aad18c998ad5aad5aac5a2dcbbf7eedd
        !hex    abd5828080a08000c0aad5aad5aad5aad5aad5aac48895a2d488d1a2c48a95a2
        !hex    d4a895aad5aad5aad5aad5aad5aa8000c00000502a552a558100000000000000
        !hex    8ad188c5a8c4000000000000000090552a552a0501a000000000000000000000
        !hex    c080808080d5eeddbbf7aed4aad5aad5aad1aad58ad5aad5aad5aadcbbf7ead5
        !hex    aa85808080a08000c0aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aa8000c0aad5aad5aad5aad5aad5aad5aad5aa
        !hex    d5aad5aad5aad5aad5aad5aad5aad5aad5aad5aad5aa00000000000000000000

; 
; Original game entry point.
; 
OriginalEntry
        jmp     EarlyInit

; 
; Three 256-byte tables, used to compute multiplication and division.
; 
math_table1
        !hex    08002032404a525960656a6e7276797d808285878a8c8e9092949698999b9d9e
        !hex    a0a1a2a4a5a6a7a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9b9babbbcbdbdbebf
        !hex    c0c0c1c2c2c3c4c4c5c6c6c7c7c8c9c9cacacbcccccdcdcececfcfd0d0d1d1d2
        !hex    d2d3d3d4d4d5d5d5d6d6d7d7d8d8d9d9d9dadadbdbdbdcdcdddddddedededfdf
        !hex    e0e0e0e1e1e1e2e2e2e3e3e3e4e4e4e5e5e5e6e6e6e7e7e7e7e8e8e8e9e9e9ea
        !hex    eaeaeaebebebececececededededeeeeeeeeefefefeff0f0f0f1f1f1f1f1f2f2
        !hex    f2f2f3f3f3f3f4f4f4f4f5f5f5f5f5f6f6f6f6f7f7f7f7f7f8f8f8f8f9f9f9f9
        !hex    f9fafafafafafbfbfbfbfbfcfcfcfcfcfdfdfdfdfdfdfefefefefeffffffffff
math_table2
        !hex    030000b8004db8d600704db4b86ad60500cc70ef4d8eb4c1b89a6a28d6750589
        !hex    006ccc2370b4ef224d718ea4b4bdc1bfb8ac9a856a4b2801d6a7753f05c98946
        !hex    00b76c1dcc7923cb7013b452ef8a22b94de071008e1aa42db439bd40c141bf3c
        !hex    b832ac249a1085f86adb4bba2895016cd63fa70e75da3fa20567c92989e846a3
        !hex    005cb7126cc51d75cc2379ce2377cb1e70c21364b40352a1ef3d8ad6226eb903
        !hex    4d97e02971b900478ed41a5fa4e82d70b4f7397bbdff4081c1014180bffe3c7a
        !hex    b8f5326face8245f9ad5104a85bef8316aa3db134b83baf1285f95cb01366ca1
        !hex    d60a3f73a7db0e4275a7da0c3f71a2d405366798c9f9295989b8e8174675a3d2
math_table3
        !hex    0101010101010101010101010101010101010101010101010101010101010101
        !hex    0202020202020202020202020202020202020203030303030303030303030303
        !hex    0404040404040404040404050505050505050506060606060606070707070707
        !hex    08080808080809090909090a0a0a0a0b0b0b0b0c0c0c0c0d0d0d0e0e0e0e0f0f
        !hex    10101011111112121313131414151516161717181819191a1a1b1c1c1d1d1e1f
        !hex    202021222223242526262728292a2b2c2d2e2f3031323334353638393a3b3d3e
        !hex    404142444547484a4c4d4f51525456585a5c5e60626467696b6d707275777a7d
        !hex    808285888b8e9194989b9ea2a5a9adb1b5b8bdc1c5c9ced2d7dbe0e5eaeff5fa
mod7_table
        !hex    0102030405060001020304050600010203040506000102030405060001020304
        !hex    0506000102030405060001020304050600010203040506000102030405060001
        !hex    0203040506000102030405060001020304050600010203040506000102030405
        !hex    0600010203040506000102030405060001020304050600010203040506000102
        !hex    0304050600010203040506000102030405060001020304050600010203040506
        !hex    0001020304050600010203040506000102030405060001020304050600010203
        !hex    0405060001020304050600010203040506000102030405060001020304050600
        !hex    0102030405060001020304050600010203040506000102030405060001020304
div7_table
        !hex    0101010101010202020202020203030303030303040404040404040505050505
        !hex    0505060606060606060707070707070708080808080808090909090909090a0a
        !hex    0a0a0a0a0a0b0b0b0b0b0b0b0c0c0c0c0c0c0c0d0d0d0d0d0d0d0e0e0e0e0e0e
        !hex    0e0f0f0f0f0f0f0f101010101010101111111111111112121212121212131313
        !hex    1313131314141414141414151515151515151616161616161617171717171717
        !hex    18181818181818191919191919191a1a1a1a1a1a1a1b1b1b1b1b1b1b1c1c1c1c
        !hex    1c1c1c1d1d1d1d1d1d1d1e1e1e1e1e1e1e1f1f1f1f1f1f1f2020202020202021
        !hex    2121212121212222222222222223232323232323242424242424242525252525
; 
; For custom RWTS: convert 6-bit value to 8-bit disk byte.
; 
rwts_encode62
        !hex    96979a9b9d9e9fa6a7abacadaeafb2b3b4b5b6b7b9babbbcbdbebfcbcdcecfd3
        !hex    d6d7d9dadbdcdddedfe5e6e7e9eaebecedeeeff2f3f4f5f6f7f9fafbfcfdfeff
L4543   !fill   14,$00     ;? (read/write)
color_indices
        !fill   6,$00
; 
sound_disab_flag
        !byte   $00        ;bool 00/ff: is sound disabled?
; 
; Game settings toggled during pause mode.
; 
ptb_kbd_dampening
        !byte   $00        ;bool 00/ff: pause 'D': keyboard dampening enabled?
ptb_kbd_recent
        !byte   $00        ;bool 00/ff: pause 'A': disable recentering
ptb_pausecmd_x
        !byte   $00        ;bool 00/ff: pause 'X': ? odd things
ptb_kbd_flash
        !byte   $00        ;bool 00/ff: pause 'F': flash hostiles on radar
ptb_joy_y_flip
        !byte   $00        ;bool 00/ff: pause 'Y': joy y_axis flipped?
ptb_joy_axis_flip
        !byte   $00        ;bool 00/ff: pause 'J': joy both axes flipped?
ptb_joy_enab
        !byte   $00        ;bool 00/ff: pause 'K': joystick enabled?
ptb_lower_case
        !byte   $00        ;bool 00/ff: pause 'U': lower-case allowed?
ptb_pausecmd_t
        !byte   $00        ;bool 00/ff: pause 'T': disk vs. tape (not for A2)
; 
unused_thing1
        !byte   $00        ;written twice, never read
joystick_found_nr
        !byte   $0b        ;set to $FF if paddles exist by unref'd SEC3 code
; 
; Key commands.  These map 1:1 with the state toggles above, starting at $4558.
; 
pause_key_cmds
        !byte   'D'
        !byte   'A'
        !byte   'X'
        !byte   'F'
        !byte   'Y'
        !byte   'J'
        !byte   'K'
        !byte   'U'
        !byte   'T'
        !fill   1,$60      ;unused

; 
; Early initialization, no longer needed.
; 
        !zone   Z003b6d
.src_ptr =      $0a
.dst_ptr =      $31
.XX12   =       $74
.des_sub =      $d0
EarlyInit
        lda     #$00       ;copy SCRN from $200-9ff to $2000-27ff
        sta     .src_ptr
        lda     #$02
        sta     .src_ptr+1
        lda     #$00
        sta     .dst_ptr
        lda     #$20
        sta     .dst_ptr+1
        ldx     #$07
        ldy     #$00
@L4581  lda     (.src_ptr),y
        sta     (.dst_ptr),y
        iny
        bne     @L4581
        inc     .src_ptr+1
        inc     .dst_ptr+1
        dex
        bpl     @L4581
        jsr     Descramble ;descramble the code
; 
; Start here to bypass the no-longer-needed copy of SCRN and the descrambler. 
; (The original start is $4000.)
; 
NewEntry
        lda     #$30       ;late patch to joystick code?
        sta     _set_by_init+1
        nop
        nop
        jsr     InitSystem
        jmp     InitGame

; 
; Most of the code is scrambled when loaded from disk.  This de-scrambles it.
; 
Descramble
        lda     #$e9       ;check for end when Y=E9
        sta     PLAYER_STATE ; so last byte we tweak is $xxEA
        lda     #$45       ;stop when we hit $45E9
        sta     PLAYER_STATE+1
        lda     #$bf       ;first byte is $BFFE
        ldy     #$fe
        ldx     #$15       ;initial sub value
        jsr     @DoDescram
        lda     #$5f
        sta     PLAYER_STATE
        lda     #$0b       ;stop when we hit $B5F
        sta     PLAYER_STATE+1
        lda     #$1f       ;start at $1FFF
        ldy     #$ff
        ldx     #$69       ;initial value
@DoDescram
        stx     .des_sub
        sta     .src_ptr+1
        lda     #$00
        sta     .src_ptr
@DesLoop
        lda     (.src_ptr),y ;get old value
        sec
        sbc     .des_sub   ;subtract rolling sub
        sta     (.src_ptr),y ;store it
        sta     .des_sub   ;update rolling sub
        tya                ;Y == 0?
        bne     @NoDec     ;not yet
        dec     .src_ptr+1 ;yes, dec high byte
@NoDec  dey                ;advance
        cpy     PLAYER_STATE ;do we need to check for done?
        bne     @DesLoop   ;not here
        lda     .src_ptr+1 ;check the ptr high byte
        cmp     PLAYER_STATE+1 ;reached the end?
        bne     @DesLoop   ;not yet
        rts

        !hex    b7aa4523

GOIN    jsr     RES2       ;BBC .GOIN
        jsr     DrawOctagonRings
        lda     #$00
        sta     player_speed
        sta     player_laser_temp
        sta     $69
        lda     #$ff
        sta     $d4
        sta     $d5
        sta     $d6
        ldy     #$2c
        jsr     LongDelay
        lda     $028f
        and     #$03
        bne     @L461B
        lda     kill_score+1
        beq     @L4666
        lda     ship_state2
        lsr
        bne     @L4666
        jmp     L62FA

@L461B  cmp     #$03
        bne     @L4622
        jmp     L62E9

@L4622  lda     ship_state2
        cmp     #$02
        bne     @L4666
        lda     $028f
        and     #$0f
        cmp     #$02
        bne     @L463C
        lda     kill_score+1
        cmp     #$05
        bcc     @L4666
        jmp     L62B7

@L463C  cmp     #$06
        bne     @L4651
        lda     $0290
        cmp     #$d7
        bne     @L4666
        lda     $0291
        cmp     #$54
        bne     @L4666
        jmp     L62C7

@L4651  cmp     #$0a
        bne     @L4666
        lda     $0290
        cmp     #$3f
        bne     @L4666
        lda     $0291
        cmp     #$48
        bne     @L4666
        jmp     L62D5

@L4666  jmp     L7F2D

        !hex    a928788df003a97e8df1035860fb04f708ef10df20bf407f80 ;unreferenced code?

; 
; Updates pitch / roll.
; 
UpdateShipControls
        lda     data_buffer
        sta     rng_state
        ldx     roll_velocity
        jsr     L61DA
        jsr     L61DA
        txa
        eor     #$80
        tay
        and     #$80
        sta     $6c
        stx     roll_velocity
        eor     #$80
        sta     $6d
        tya
        bpl     @L46A5
        eor     #$ff
        clc
        adc     #$01
@L46A5  lsr
        lsr
        cmp     #$08
        bcs     @L46AC
        lsr
@L46AC  sta     $6b
        ora     $6c
        sta     $b9
        ldx     pitch_velocity
        jsr     L61DA
        txa
        eor     #$80
        tay
        and     #$80
        stx     pitch_velocity
        sta     $a8
        eor     #$80
        sta     $a7
        tya
        bpl     @L46CA
        eor     #$ff
@L46CA  adc     #$04
        lsr
        lsr
        lsr
        lsr
        cmp     #$03
        bcs     @L46D5
        lsr
@L46D5  sta     $67
        ora     $a7
        sta     $66
        lda     cmd_throttle_up
        beq     @NotThrotUp
        lda     player_speed
        cmp     #$28
        bcs     @NotThrotUp
        inc     player_speed
@NotThrotUp
        lda     cmd_throttle_down
        beq     @NotThrotDn
        dec     player_speed
        bne     @NotThrotDn
        inc     player_speed
@NotThrotDn
        lda     cmd_unarm_mssl
        and     missile_armed_flag
        beq     @NotUnarmMsl
        ldy     #$08
        jsr     L75E6
        jsr     Noise1
        lda     #$00
        sta     PLAYER_STATE+48
@NotUnarmMsl
        lda     missile_thing
        bpl     @NotTargMsl
        lda     cmd_targ_mssl
        beq     @NotTargMsl
        ldx     missile_armed_flag
        beq     @NotTargMsl
        sta     PLAYER_STATE+48
        ldy     #$0c
        jsr     DrawIndicator
@NotTargMsl
        lda     cmd_fire_mssl
        beq     @NotFireMsl
        lda     missile_thing
        bmi     @NotEcm
        jsr     L5C3A
@NotFireMsl
        lda     cmd_energy_bomb
        beq     @NoBomb
        lda     have_energy_bomb
        bmi     @NoBomb
        asl     have_energy_bomb
        beq     @NoBomb
        jsr     DetonateBomb
@NoBomb lda     cmd_dock_off
        beq     @NotDockOff
        lda     #$00
        sta     computer_dock_flag
@NotDockOff
        lda     cmd_escape_cap ;trying to eject?
        and     have_escape_pod ;...with the appropriate equipment?
        beq     @InWitch   ;nope
        lda     witch_space_flag ;are we in witch space?
        bne     @InWitch   ;yes, no escape
        jmp     EjectEscape

@InWitch
        lda     cmd_local_jump ;check 'J' key
        beq     @NotJump
        jsr     LocalJump
@NotJump
        lda     cmd_ecm    ;check 'E' key
        and     have_ecm   ;do we have an ECM?
        beq     @NotEcm    ;no
        lda     ecm_active_flag ;any ECM active?
        bne     @NotEcm    ;yes
        dec     player_ecm_active
        jsr     ActivateEcm
@NotEcm lda     cmd_dock_on ;check 'C' key
        and     have_docking_comp
        beq     @L4770
        sta     computer_dock_flag
@L4770  lda     #$00
        sta     $7e
        sta     $aa
        lda     player_speed
        lsr
        ror     $aa
        lsr
        ror     $aa
        sta     $ab
        lda     main_dec2_thing
        bne     @L47B0
        lda     cmd_fire_laser
        beq     @L47B0
        lda     player_laser_temp
        cmp     #$f2
        bcs     @L47B0
        ldx     PLAYER_STATE+49
        lda     $029f,x
        beq     @L47B0
        pha
        and     #$7f
        sta     $7e
        sta     PLAYER_STATE+47
        jsr     MakeNoise5
        jsr     L6217
        pla
        bpl     @L47AB
        lda     #$00
@L47AB  and     #$fa
        sta     main_dec2_thing
@L47B0  ldx     #$00
L47B2   stx     $b0
        lda     PLAYER_STATE,x
        bne     @L47BC
        jmp     L497A

@L47BC  sta     $b8
        jsr     GetInfo
        ldy     #$24
@L47C3  lda     (polyobj_ptr),y
        sta     polyobj_xpos_lo,y
        dey
        bpl     @L47C3
        lda     $b8
        bmi     @L47FC
        asl
        tay
        lda     hull_addr_lo,y
        sta     hull_ptr
        lda     hull_addr_hi,y
        sta     hull_ptr+1
        lda     have_energy_bomb
        bpl     @L47FC
        cpy     #$04
        beq     @L47FC
        cpy     #$3a
        beq     @L47FC
        cpy     #$3e
        bcs     @L47FC
        lda     polyobj_vis
        and     #$20
        bne     @L47FC
        asl     polyobj_vis
        sec
        ror     polyobj_vis
        ldx     $b8
        jsr     CountKill
@L47FC  jsr     MVEIT
        ldy     #$24
@L4801  lda     polyobj_xpos_lo,y
        sta     (polyobj_ptr),y
        dey
        bpl     @L4801
        lda     polyobj_vis
        and     #$a0
        jsr     L7E20
        bne     @L4863
        lda     polyobj_xpos_lo
        ora     polyobj_ypos_lo
        ora     polyobj_zpos_lo
        bmi     @L4863
        ldx     $b8
        bmi     @L4863
        cpx     #$02
        beq     @L4866
        and     #$c0
        bne     @L4863
        cpx     #$01
        beq     @L4863
        lda     have_fuel_scoop
        and     INWK+5
        bpl     L48A2
        cpx     #$05
        beq     @L4843
        ldy     #$00       ;fuel scoop / debris info in hull def
        lda     (hull_ptr),y
        lsr                ;get high nibble (fuel scoop info)
        lsr
        lsr
        lsr
        beq     L48A2
        adc     #$01
        bne     @L4848
@L4843  jsr     GetRandom
        and     #$07
@L4848  jsr     L63E3
        ldy     #$4e
        bcs     L4890
        ldy     $02f0
        adc     player_cargo,y
        sta     player_cargo,y
        tya
        adc     #$d0       ;Food, Textiles, ...
        jsr     PrintMessageBriefly
        asl     $30
        sec
        ror     $30
@L4863  jmp     L48B1

@L4866  lda     data_buffer+73
        and     #$04
        bne     L4887
        lda     polyobj_mox2_hi
        cmp     #$d6
        bcc     L4887
        jsr     L8274
        lda     $70
        cmp     #$59
        bcc     L4887
        lda     $1c
        and     #$7f
        cmp     #$50
        bcc     L4887
GOIN_jmp
        jmp     GOIN

L4887   lda     player_speed
        cmp     #$05
        bcc     L489A
        jmp     GameOver

L4890   jsr     MakeNoise2
        asl     polyobj_vis
        sec
        ror     polyobj_vis
        bne     L48B1

L489A   lda     #$01
        sta     player_speed
        lda     #$05
        bne     L48AB

L48A2   asl     polyobj_vis
        sec
        ror     polyobj_vis
        lda     $2f
        sec
        ror
L48AB   jsr     L74B4
        jsr     MakeNoise2
L48B1   lda     $30
        bpl     @L48B8
        jsr     SCAN
@L48B8  lda     displayed_screen
        bne     @L492B
        jsr     L93C2
        jsr     L5BD3
        bcc     @L4928
        lda     PLAYER_STATE+48
        beq     @L48D3
        jsr     MakeNoise3
        ldx     $b0
        ldy     #$14
        jsr     L75E8
@L48D3  lda     $7e
        beq     @L4928
        ldx     #$0f
        jsr     L954E
        lda     $b8
        cmp     #$02
        beq     @L4923
        cmp     #$1f
        bcc     @L48F0
        lda     $7e
        cmp     #$17
        bne     @L4923
        lsr     $7e
        lsr     $7e
@L48F0  lda     $2f
        sec
        sbc     $7e
        bcs     @L4921
        asl     polyobj_vis
        sec
        ror     polyobj_vis
        lda     $b8
        cmp     #$07
        bne     @L4912
        lda     $7e
        cmp     #$32
        bne     @L4912
        jsr     GetRandom
        ldx     #$08
        and     #$03
        jsr     L4AC0
@L4912  ldy     #$04
        jsr     L4AB3
        ldy     #$05
        jsr     L4AB3
        ldx     $b8
        jsr     CountKill
@L4921  sta     $2f
@L4923  lda     $b8
        jsr     L5C59
@L4928  jsr     DrawObject
@L492B  ldy     #$23
        lda     $2f
        sta     (polyobj_ptr),y
        lda     $30
        bmi     @NoBounty
        lda     polyobj_vis
        bpl     @L4965
        and     #$20
        beq     @L4965
        lda     $30
        and     #$40
        ora     player_fug_inno
        sta     player_fug_inno
        lda     PLAYER_STATE+54
        ora     witch_space_flag ;no bounties in witch space
        bne     @NoBounty
        ldy     #$0a       ;bounty value, low
        lda     (hull_ptr),y
        beq     @NoBounty  ;(shouldn't we check the high byte?)
        tax
        iny                ;bounty value, high
        lda     (hull_ptr),y
        tay
        jsr     AddCredits
        lda     #$00       ;invalid token?
        jsr     PrintMessageBriefly ;(should display current cash)
@NoBounty
        jmp     L797D

@L4965  lda     $b8
        bmi     @L496E
        jsr     L7E13
        bcc     @NoBounty
@L496E  ldy     #$1f
        lda     polyobj_vis
        sta     (polyobj_ptr),y
        ldx     $b0
        inx
        jmp     L47B2

L497A   lda     have_energy_bomb
        bpl     @L498A
        jsr     L4B00
        asl     have_energy_bomb
        bmi     @L498A
        jsr     DrawBombAnim
@L498A  lda     $b6
        and     #$07
        bne     @L49F6
        ldx     $d6
        bpl     @L49A2
        ldx     $d5
        jsr     L7439
        stx     $d5
        ldx     $d4
        jsr     L7439
        stx     $d4
@L49A2  sec
        lda     have_energy_unit
        adc     $d6
        bcs     @L49AC
        sta     $d6
@L49AC  lda     witch_space_flag
        bne     @L49F3
        lda     $b6
        and     #$1f
        bne     @L49FF
        lda     PLAYER_STATE+11
        bne     @L49F3
        tay
        jsr     L5261
        bne     @L49F3
        ldx     #$1c
@L49C4  lda     data_buffer,x
        sta     polyobj_xpos_lo,x
        dex
        bpl     @L49C4
        inx
        ldy     #$09
        jsr     L523E
        bne     @L49F3
        ldx     #$03
        ldy     #$0b
        jsr     L523E
        bne     @L49F3
        ldx     #$06
        ldy     #$0d
        jsr     L523E
        bne     @L49F3
        lda     #$c0
        jsr     L7E15
        bcc     @L49F3
        jsr     L785B
        jsr     L74FE
@L49F3  jmp     @L4A7B

@L49F6  lda     witch_space_flag
        bne     @L49F3
        lda     $b6
        and     #$1f
@L49FF  cmp     #$0a
        bne     @L4A30
        lda     #$32
        cmp     $d6
        bcc     @L4A0D
        asl
        jsr     PrintMessageBriefly
@L4A0D  ldy     #$ff
        sty     lcoord_swap_flag-1
        iny
        jsr     L525F
        bne     @L4A7B
        jsr     L526D
        bcs     @L4A7B
        sbc     #$24
        bcc     @L4A2D
        sta     $ae
        jsr     TwoByteSqrt
        lda     $ad
        sta     lcoord_swap_flag-1
        bne     @L4A7B
@L4A2D  jmp     GameOver

@L4A30  cmp     #$0f
        bne     @L4A3D
        lda     computer_dock_flag
        beq     @L4A7B
        lda     #$7b
        bne     @L4A78

@L4A3D  cmp     #$14
        bne     @L4A7B
        lda     #$1e
        sta     PLAYER_STATE+46
        lda     PLAYER_STATE+11
        bne     @L4A7B
        ldy     #$25
        jsr     L5261
        bne     @L4A7B
        jsr     L526D
        eor     #$ff
        adc     #$1e
        sta     PLAYER_STATE+46
        bcs     @L4A2D
        cmp     #$e0
        bcc     @L4A7B
        lda     have_fuel_scoop
        beq     @L4A7B
        lda     $ab
        lsr
        adc     player_fuel
        cmp     #$46
        bcc     @L4A73
        lda     #$46
@L4A73  sta     player_fuel
        lda     #$a0       ;"Fuel Scoops On"
@L4A78  jsr     PrintMessageBriefly
@L4A7B  lda     PLAYER_STATE+47
        beq     @L4A8F
        lda     main_dec2_thing
        cmp     #$08
        bcs     @L4A8F
        jsr     L6236
        lda     #$00
        sta     PLAYER_STATE+47
@L4A8F  lda     player_ecm_active
        beq     @L4A99
        jsr     L743C
        beq     @L4AA9
@L4A99  lda     ecm_active_flag
        beq     @L4AAC
        ldy     #$14
        ora     #$c0
        tax
        jsr     MakeNoise4
        dec     ecm_active_flag
        bne     @L4AAC
@L4AA9  jsr     L9512
@L4AAC  lda     displayed_screen
        bne     L4ACD
        jmp     L5045

L4AB3   jsr     GetRandom
        bpl     L4ACD
        tya
        tax
        ldy     #$00
        and     (hull_ptr),y
        and     #$0f
L4AC0   sta     $bd
        beq     L4ACD
@L4AC4  lda     #$00
        jsr     LaunchObject1
        dec     $bd
        bne     @L4AC4
L4ACD   rts

; Energy bomb detonations draw a jagged horizontal line several times while
; making noises.
DrawBombAnim
        lda     displayed_screen ;check which view we're showing
        bne     @NotSpace  ;not space, bail
        ldy     #$01
        lda     L4B3C
        sta     .XX12
        lda     L4B46
        sta     .XX12+1
@Loop   jsr     MakeNoise7
        lda     .XX12
        sta     $6e
        lda     .XX12+1
        sta     $6f
        lda     L4B3C,y
        sta     $70
        sta     .XX12
        lda     L4B46,y
        sta     $71
        sta     .XX12+1
        jsr     DrawLine
        iny
        cpy     #$0a
        bcc     @Loop
@NotSpace
        rts

L4B00   jsr     @L4B03
@L4B03  jsr     @L4B06
@L4B06  jsr     MakeNoise6
        jsr     DrawBombAnim
DetonateBomb
        ldy     #$00
@Loop   jsr     GetRandom
        and     #$7f
        adc     #$03
        sta     L4B46,y
        txa
        and     #$1f
        clc
        adc     @L4B32,y
        sta     L4B3C,y
        iny
        cpy     #$0a       ;set 10 values
        bcc     @Loop
        ldx     #$00
        stx     L4B3C+9
        dex
        stx     L4B3C
        bcs     DrawBombAnim

@L4B32  !hex    e0e0c0a0806040200000
L4B3C   !hex    00000000000000000000
L4B46   !hex    00000000000000000000

PrintNavyCapName
        lda     #$d9       ;Curruthers, Fosdyke Smythe, Fortesque
        bne     L4B56

PrintDockDcPlus
        lda     #$dc       ;"last seen" / "believed to have jumped"
L4B56   clc
        adc     ship_state2
        bne     PrintDockedStr
; 
; Prints a string from the extended set of docked messages.
; 
        !zone   Z00415c
.token_ptr =    $5e
PrintExtDockedStr
        pha                ;preserve A-reg
        tax
        tya
        pha                ;preserve Y-reg
        lda     .token_ptr
        pha
        lda     .token_ptr+1
        pha
        lda     #<ext_docked_text
        sta     .token_ptr
        lda     #>ext_docked_text
        bne     PrintDocked2

; 
; Print a message from a tokenized string while docked.
; 
; On entry:
;   A-reg: message index
; 
; On exit:
;   A-reg and Y-reg preserved
; 
PrintDockedStr
        pha                ;preserve A-reg
        tax
        tya                ;preserve Y-reg
        pha
        lda     .token_ptr ;preserve pointer
        pha                ;(because of recursion)
        lda     .token_ptr+1
        pha
        lda     #<docked_text ;search docked text table
        sta     .token_ptr
        lda     #>docked_text
; X-reg has message index.
PrintDocked2
        sta     .token_ptr+1
        ldy     #$00
@L4B82  lda     (.token_ptr),y ;get data
        eor     #EOR_DOCKED ;decrypt it
        bne     @NotEnd    ;not end of string, branch
        dex                ;dec index
        beq     @GotString ;found the one we want
@NotEnd iny
        bne     @L4B82
        inc     .token_ptr+1
        bne     @L4B82
@GotString
        iny                ;move to start of string
        bne     @NoInc
        inc     .token_ptr+1
@NoInc  lda     (.token_ptr),y ;get token
        eor     #EOR_DOCKED ;decrypt
        beq     @StrEnd    ;end of string, branch
        jsr     PrintDockedToken
        jmp     @GotString

@StrEnd pla                ;restore pointer
        sta     .token_ptr+1
        pla
        sta     .token_ptr
        pla
        tay                ;restore Y-reg
        pla                ;restore A-reg
        rts

; 
; Print a "docked" text token:
;   $00: invalid
;   $01-1f: format token (invokes function)
;   $20-5a: ASCII
;   $5b-80: planet description tokens
;   $81-d6: message index 0-55
;   $d7-ff: digrams
; 
; On entry:
;   A-reg: token to print
; 
; Y-reg is preserved.
; 
PrintDockedToken
        cmp     #$20
        bcc     PrintDockedFmt
        bit     txt_flight_flag ;flight string mode on?
        bpl     @DoDocked  ;no
        tax                ;yes, handle as flight string
        tya
        pha
        lda     .token_ptr
        pha
        lda     .token_ptr+1
        pha
        txa
        jsr     PrintFlightToken
        jmp     Restore5ePtr

@DoDocked
        cmp     #'['       ;<= 'Z'?
        bcc     PrintDockedChar ;yes, print plain character
        cmp     #$81
        bcc     PrintPlanetDescToken
        cmp     #$d7       ;is it a digram?
        bcc     PrintDockedStr ;no, canned string
        sbc     #$d7       ;get digram index
        asl
        pha
        tax
        lda     docked_digram_tab,x
        jsr     PrintDockedChar
        pla
        tax
        lda     docked_digram_tab+1,x
PrintDockedChar
        cmp     #'A'       ;is it a number or punctuation?
        bcc     @DoPrintChar ;yes, don't mess with it
        bit     text_ucase_flag ;upper-case flag set?
        bmi     @MakeUpper ;yes, make it upper
        bit     txt_lcase_flag ;lower-case flag set?
        bmi     @MakeLower ;yes, make it lower
@MakeUpper
        ora     text_ucase_mask
@MakeLower
        and     text_lcase_mask
@DoPrintChar
        jmp     PrintChar

PrintDockedFmt
        tax                ;A-reg holds $01-1f
        tya                ;preserve Y-reg
        pha
        lda     .token_ptr ;preserve $5e/5f
        pha
        lda     .token_ptr+1
        pha
        txa
        asl                ;double it
        tax
        lda     token_print_funcs-2,x ;get address of function to call
        sta     @_CallAddr+1
        lda     token_print_funcs-1,x
        sta     @_CallAddr+2
        txa
        lsr
@_CallAddr
        jsr     PrintChar  ;call it
Restore5ePtr
        pla                ;restore $5e/5f
        sta     .token_ptr+1
        pla
        sta     .token_ptr
        pla                ;restore Y-reg
        tay
        rts

PrintPlanetDescToken
        sta     $0a        ;$5b-80
        tya
        pha
        lda     .token_ptr
        pha
        lda     .token_ptr+1
        pha
        jsr     GetRandom
        tax
        lda     #$00
        cpx     #$33
        adc     #$00
        cpx     #$66
        adc     #$00
        cpx     #$99
        adc     #$00
        cpx     #$cc
        ldx     $0a
        adc     planet_desc_adj-91,x
        jsr     PrintDockedStr
        jmp     Restore5ePtr

ClearUcaseMask
        lda     #$00
        !byte   $2c
SetUcaseMask
        lda     #$20
        sta     text_ucase_mask
        lda     #$00
        sta     text_ucase_flag
        rts

T4C56   lda     #$06
        sta     text_hposn
        lda     #$ff
        sta     txt_lcase_flag
        rts

T4C60   lda     #$01
        sta     text_hposn
        jmp     PrintFlightHud

SetUpperMask
        lda     #$80
        sta     text_ucase_flag
        lda     #$20
        sta     text_ucase_mask
        rts

SetFlightTokFlag
        lda     #$80
        sta     text_mod_flags
        lda     #$ff
        !byte   $2c
ClearFlightTokFlag
        lda     #$00
        sta     txt_flight_flag
        rts

SetBufferFlag
        lda     #$80
        !byte   $2c
ClearBufferFlag
        lda     #$00
        sta     txt_buffer_flag
        asl                ;now A-reg=0 either way
        sta     txt_buffer_index ;set index=0
        rts

PrintSpeciesIan
        lda     text_mod_flags
        and     #$bf
        sta     text_mod_flags
        lda     #$03       ;selected planet
        jsr     PrintFlightToken
        ldx     txt_buffer_index
        lda     <BUFFER_0100+255,x ;check the last letter
        jsr     IsVowel    ;is it a vowel?
        bcc     @NotVowel  ;no
        dec     txt_buffer_index ;yes, back up one
@NotVowel
        lda     #$99       ;"-ian" suffix, e.g. "fubarian"
        jmp     PrintDockedStr

RandomName
        jsr     LcaseDF
        jsr     GetRandom  ;random number of digrams
        and     #$03
        tay
@More   jsr     GetRandom  ;random digram
        and     #$3e
        tax
        lda     docked_digram_tab+2,x
        jsr     PrintDockedChar
        lda     docked_digram_tab+3,x
        jsr     PrintDockedChar
        dey
        bpl     @More
        rts

LcaseDF lda     #$df
        sta     text_lcase_mask
        rts

; 
; Returns with carry set if A-reg holds A/E/I/O/U.
; 
IsVowel ora     #$20       ;convert to lower
        cmp     #'a'
        beq     @L4CE5
        cmp     #'e'
        beq     @L4CE5
        cmp     #'i'
        beq     @L4CE5
        cmp     #'o'
        beq     @L4CE5
        cmp     #'u'
        beq     @L4CE5
        clc
@L4CE5  rts

token_print_funcs
        !word   ClearUcaseMask ;$01
        !word   SetUcaseMask ;$02
        !word   PrintFlightToken ;$03 - print flight token $03
        !word   PrintFlightToken ;$04 - print flight token $04
        !word   ClearFlightTokFlag ;$05
        !word   SetFlightTokFlag ;$06
        !word   PrintChar  ;$07 [beep]
        !word   T4C56      ;$08 - htab 6, set lcase flag
        !word   T4C60      ;$09 - print flight HUD text?
        !word   PrintChar  ;$0a (LF)
        !word   T4EA9      ;$0b - clears screen??  (first part of disk access menu str)
        !word   PrintChar  ;$0c (FF)
        !word   SetUpperMask ;$0d
        !word   SetBufferFlag ;$0e
        !word   ClearBufferFlag ;$0f
        !word   PrintCharA ;$10 - print 'A'
        !word   PrintSpeciesIan ;$11 - print species + "-ian"
        !word   RandomName ;$12 - random set of digrams
        !word   LcaseDF    ;$13
        !word   PrintChar  ;$14 (Ctrl+T)
        !word   ClearLines ;$15
        !word   WaitKeyDrawHud ;$16
        !word   Vposn9_SetMask ;$17
        !word   WaitForKey ;$18 - wait for key
        !word   PrintIncomingMessage ;$19
        !word   InputName  ;$1a
        !word   PrintNavyCapName ;$1b
        !word   PrintDockDcPlus ;$1c
        !word   Vposn5_SetMask ;$1d
        !word   PrintDiskTape
        !word   PrintTapeDisk
        !word   PrintChar  ;$20
; Digrams used in docked string construction and planet descriptions.  This
; defines 13 pairs, although the planet description code skips the first one. 
; The code accepts a value from $00-28, so we use entries $00-1a in the flight
; digram table as well.
; 
; 00 fflf  04 IT   08 ON   0c NO
; 01 AB    05 IL   09 LO
; 02 OU    06 ET   0a NU
; 03 SE    07 ST   0b TH
docked_digram_tab
        !byte   $0c
        !byte   $0a
        !text   "ABOUSEITILETSTONLONUTHNO"
; Digrams used in flight string construction:
; 
; 00 AL   08 US   10 ER   18 ED
; 01 LE   09 ES   11 AT   19 OR
; 02 XE   0a AR   12 EN   1a QU
; 03 GE   0b MA   13 BE   1b AN
; 04 ZA   0c IN   14 RA   1c TE
; 05 CE   0d DI   15 LA   1d IS
; 06 BI   0e RE   16 VE   1e RI
; 07 SO   0f A?   17 TI   1f ON
; 
; For example, "HARMLESS" would be 48 8a 4d 81 53 53 (H AR M LE S S).  Strings
; are EORed with $23 (to make them harder to find?).
flight_digram_tab
        !text   "ALLEXEGEZACEBISOUSESARMAINDIREA?ERATENBERALAVETIEDORQUANTEISRI"
        !text   "ON"
L4D80   !text   ":0.E."
commander_name
        !text   "jameson"
save_game_state
        !hex    0d00000000000000000000000000000000000000000000000000000000000000
        !hex    00000000000000000000000000000000000000000000100f1100031c0e00000a
        !hex    00113a070908000000008000
scramble_thing
        !fill   22,$00
; Default save-game data.
        !text   ":0.E."
commander_jameson
        !text   "JAMESON",$0d
        !byte   $00
        !byte   $14
        !byte   $ad
        !byte   $4a
        !byte   $5a
        !byte   $48
        !byte   $02
        !byte   $53
        !byte   $b7
        !byte   $00
        !byte   $00
        !byte   $03
        !byte   $e8
        !byte   $46
        !byte   $00
        !byte   $00
        !byte   $0f
        !fill   5,$00
        !byte   $16
        !fill   28,$00
        !byte   $03
        !byte   $00
        !byte   $10
        !byte   $0f
        !byte   $11
        !byte   $00
        !byte   $03
        !byte   $1c
        !byte   $0e
        !byte   $00
        !byte   $00
        !byte   $0a
        !byte   $00
        !byte   $11
        !byte   $3a
        !byte   $07
        !byte   $09
        !byte   $08
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   $80
        !byte   $aa
        !byte   $27
        !byte   $03
        !fill   13,$00
; end of data
        !byte   $00
        !byte   $00
        !byte   $00
L4E58   !byte   $00
        !byte   $10
        !byte   $10
        !fill   6,$14
        !fill   6,$0c
        !byte   $14
        !fill   7,$0c
        !byte   $10
        !fill   5,$0c
        !byte   $18
        !byte   $0c
        !byte   $0c
        !byte   $00
        !byte   $0c
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   $00
L4E7E   !byte   $00
L4E7F   !byte   $08
        !byte   $25
        !byte   $08
        !byte   $4a
        !byte   $08
        !byte   $6f
        !byte   $08
        !byte   $94
        !byte   $08
        !byte   $b9
        !byte   $08
        !byte   $de
        !byte   $08
        !byte   $03
        !byte   $09
        !byte   $28
        !byte   $09

L4E90   ldx     #$27
@L4E92  lda     xcoords+128,x
        cmp     #$a0
        beq     @L4E9E
        lda     #$ad
        sta     ycoords,x
@L4E9E  dex
        bpl     @L4E92
        rts

ClearKbdStrb
        bit     KBDSTRB
        rts

PrintFlightTokLine
        jsr     PrintFlightToken
T4EA9   lda     display_mode_flag ;text or hi-res?
        bmi     L4E90      ;text, branch
        lda     #19
        bne     DrawHorizontalLine

        !byte   $a9
        !byte   $17

IncTextDrawLine
        jsr     IncTextVposn
DrawHorizontalLine
        sta     $6f
        lda     #$10
        sta     $35
        ldx     #$00
        stx     $6e
        dex
        stx     $70
        jmp     DrawHorizLine ;draw horizontal line

L4EC6   jsr     L7878
        sty     $6f
        lda     #$00
        sta     $0600,y
        jmp     DrawHorizLine

        !zone   Z0044d3
.saved_y =      $06
.row_mod8 =     $07
.row_div8 =     $08
.hptr   =       $0a
.what_is_this = $b4
L4ED3   jsr     ADD
        sta     $63
        txa
        sta     $06ef,y
L4EDC   lda     $6e
        bpl     @L4EE5
        eor     #$7f
        clc
        adc     #$01
@L4EE5  eor     #$80
        tax
        lda     $6f
        and     #$7f
        cmp     #$44
        bcs     Return
        lda     $6f
        bpl     @L4EF8
        eor     #$7f
        adc     #$01
@L4EF8  sta     $d0
        lda     #$45
        sbc     $d0
; 
; Draws a 2x2 white block, i.e a rect that covers xc,yc to xc+1,yc-1.
; 
; Seems to be used to draw the stars on the galactic chart.
; 
; On entry:
;   A-reg: Y-coord
;   X-reg: X-coord
;   $b4: ?
; 
; On exit:
;   Y-reg preserved
; 
DrawStar
        sty     .saved_y   ;preserve Y-reg
        sta     .hptr+1    ;store row here temporarily
        lsr                ;divide by 8
        lsr
        lsr
        sta     .row_div8
        tay
        lda     hires_line_lo,y ;set hi-res row address, low byte
        sta     .hptr
        lda     .hptr+1    ;now fix the high byte
        and     #$07       ;compute mod 8
        sta     .row_mod8
        asl                ;multiply by 4
        asl
        adc     hires_line_hi,y ;set hi-res address, high byte
        sta     .hptr+1
        lda     mod7_table,x ;get col pixel
        asl                ;x2
        ldy     .what_is_this
        bmi     @NegB4
        adc     #14
@NegB4  cpy     #80
        ldy     div7_table,x ;get col byte
        tax
        bcs     DrawLast
        lda     hi_res_2pixel2,x ;blend first byte
        eor     (.hptr),y
        sta     (.hptr),y
        lda     hi_res_2pixel2+1,x ;anything in second byte?
        beq     @Skip2     ;no, skip that one
        iny                ;yes, blend second byte
        eor     (.hptr),y
        sta     (.hptr),y
        dey                ;back up
@Skip2  lda     .row_mod8  ;at top of 8-row section?
        beq     CalcRow    ;yes, do the bigger calculation
        lda     .hptr+1    ;move up one row
        sbc     #$03
        sta     .hptr+1
DrawLast
        lda     hi_res_2pixel2,x ;blend first byte
        eor     (.hptr),y
        sta     (.hptr),y
        lda     hi_res_2pixel2+1,x ;anything in second byte?
        beq     @Done      ;no, done
        iny                ;yes, blend second byte
        eor     (.hptr),y
        sta     (.hptr),y
@Done   ldy     .saved_y
Return  rts

CalcRow stx     .row_mod8  ;preserve X-reg
        ldx     .row_div8  ;move up one row
        lda     hires_line_lo-1,x
        sta     .hptr
        lda     hires_line_hi2-1,x
        sta     .hptr+1
        ldx     .row_mod8  ;restore X-reg
        jmp     DrawLast

; Two pixels, stored in two bytes so we don't have to special-case the ends.
hi_res_2pixel2
        !hex    0300
        !hex    0600
        !hex    0c00
        !hex    1800
        !hex    3000
        !hex    6000
        !hex    4001
; Same thing, but three pixels.
        !hex    0700
        !hex    0e00
        !hex    1c00
        !hex    3800
        !hex    7000
        !hex    6001
        !hex    4003

L4F8B   txa
        adc     $46
        sta     $9e
        lda     $47
        adc     $d0
        sta     $9f
        lda     $bc
        beq     @L4FAC
        inc     $bc
@L4F9C  ldy     $91
        lda     #$ff
        cmp     ycoords-1,y
        beq     @L500E
        sta     ycoords,y
        inc     $91
        bne     @L500E
@L4FAC  lda     $98
        sta     $6e
        lda     $99
        sta     $6f
        lda     $9a
        sta     $70
        lda     $9b
        sta     $71
        lda     $9c
        sta     $72
        lda     $9d
        sta     $73
        lda     $9e
        sta     $74
        lda     $9f
        sta     $75
        jsr     ClipLine
        bcs     @L4F9C
        lda     lcoord_swap_flag
        beq     @NoSwap
        lda     $6e
        ldy     $70
        sta     $70
        sty     $6e
        lda     $6f
        ldy     $71
        sta     $71
        sty     $6f
@NoSwap ldy     $91
        lda     ycoords-1,y
        cmp     #$ff
        bne     @L4FFA
        lda     $6e
        sta     xcoords,y
        lda     $6f
        sta     ycoords,y
        iny
@L4FFA  lda     $70
        sta     xcoords,y
        lda     $71
        sta     ycoords,y
        iny
        sty     $91
        jsr     DrawLine
        lda     $b5
        bne     @L4F9C
@L500E  lda     $9c
        sta     $98
        lda     $9d
        sta     $99
        lda     $9e
        sta     $9a
        lda     $9f
        sta     $9b
        lda     $bd
        clc
        adc     $bf
        sta     $bd
        rts

L5026   ldy     $e2
@L5028  ldx     $06e2,y
        lda     $06c8,y
        sta     $6f
        sta     $06e2,y
        txa
        sta     $6e
        sta     $06c8,y
        lda     SCRNHOLE5+4,y
        sta     .what_is_this
        jsr     L4EDC
        dey
        bne     @L5028
        rts

L5045   ldx     PLAYER_STATE+49
        beq     @L5053
        dex
        bne     @L5050
        jmp     @L513F

@L5050  jmp     L5D94

@L5053  ldy     $e2
@L5055  jsr     DV42
        lda     $ae
        lsr     $31
        ror
        lsr     $31
        ror
        ora     #$01
        sta     $ad
        lda     $0709,y
        sbc     $aa
        sta     $0709,y
        lda     SCRNHOLE5+4,y
        sta     .what_is_this
        sbc     $ab
        sta     SCRNHOLE5+4,y
        jsr     L5F3C
        sta     $63
        lda     $31
        adc     $06ef,y
        sta     $62
        sta     $ae
        lda     $6f
        adc     $63
        sta     $63
        sta     $af
        lda     $06c8,y
        sta     $6e
        jsr     L5F41
        sta     $61
        lda     $31
        adc     $06d5,y
        sta     $60
        lda     $6e
        adc     $61
        sta     $61
        eor     $6d
        jsr     MLS1
        jsr     ADD
        sta     $63
        stx     $62
        eor     $6c
        jsr     MLS2
        jsr     ADD
        sta     $61
        stx     $60
        ldx     $67
        lda     $63
        eor     $a8
        jsr     MULTS
        sta     $ad
        jsr     MUT2
        asl     $31
        rol
        sta     $d0
        lda     #$00
        ror
        ora     $d0
        jsr     ADD
        sta     $61
        txa
        sta     $06d5,y
        lda     $62
        sta     $ae
        lda     $63
        sta     $af
        lda     #$00
        sta     $31
        lda     $66
        eor     #$80
        jsr     L4ED3
        lda     $61
        sta     $6e
        sta     $06c8,y
        and     #$7f
        cmp     #$78
        bcs     @L511C
        lda     $63
        sta     $06e2,y
        sta     $6f
        and     #$7f
        cmp     #$78
        bcs     @L511C
        lda     SCRNHOLE5+4,y
        cmp     #$10
        bcc     @L511C
        sta     .what_is_this
@L5112  jsr     L4EDC
        dey
        beq     @L511B
        jmp     @L5055

@L511B  rts

@L511C  jsr     GetRandom
        ora     #$04
        sta     $6f
        sta     $06e2,y
        jsr     GetRandom
        ora     #$08
        sta     $6e
        sta     $06c8,y
        jsr     GetRandom
        ora     #$90
        sta     SCRNHOLE5+4,y
        sta     .what_is_this
        lda     $6f
        jmp     @L5112

@L513F  ldy     $e2
@L5141  jsr     DV42
        lda     $ae
        lsr     $31
        ror
        lsr     $31
        ror
        ora     #$01
        sta     $ad
        lda     $06c8,y
        sta     $6e
        jsr     L5F41
        sta     $61
        lda     $06d5,y
        sbc     $31
        sta     $60
        lda     $6e
        sbc     $61
        sta     $61
        jsr     L5F3C
        sta     $63
        lda     $06ef,y
        sbc     $31
        sta     $62
        sta     $ae
        lda     $6f
        sbc     $63
        sta     $63
        sta     $af
        lda     $0709,y
        adc     $aa
        sta     $0709,y
        lda     SCRNHOLE5+4,y
        sta     .what_is_this
        adc     $ab
        sta     SCRNHOLE5+4,y
        lda     $61
        eor     $6c
        jsr     MLS1
        jsr     ADD
        sta     $63
        stx     $62
        eor     $6d
        jsr     MLS2
        jsr     ADD
        sta     $61
        stx     $60
        lda     $63
        eor     $a8
        ldx     $67
        jsr     MULTS
        sta     $ad
        lda     $61
        sta     $af
        eor     #$80
        jsr     MUT1
        asl     $31
        rol
        sta     $d0
        lda     #$00
        ror
        ora     $d0
        jsr     ADD
        sta     $61
        txa
        sta     $06d5,y
        lda     $62
        sta     $ae
        lda     $63
        sta     $af
        lda     #$00
        sta     $31
        lda     $66
        jsr     L4ED3
        lda     $61
        sta     $6e
        sta     $06c8,y
        lda     $63
        sta     $06e2,y
        sta     $6f
        and     #$7f
        cmp     #$6e
        bcs     @L5208
        lda     SCRNHOLE5+4,y
        cmp     #$a0
        bcs     @L5208
        sta     .what_is_this
@L51FE  jsr     L4EDC
        dey
        beq     @L5207
        jmp     @L5141

@L5207  rts

@L5208  jsr     GetRandom
        and     #$7f
        adc     #$0a
        sta     SCRNHOLE5+4,y
        sta     .what_is_this
        lsr
        bcs     @L522B
        lsr
        lda     #$fc
        ror
        sta     $6e
        sta     $06c8,y
        jsr     GetRandom
        sta     $6f
        sta     $06e2,y
        jmp     @L51FE

@L522B  jsr     GetRandom
        sta     $6e
        sta     $06c8,y
        lsr
        lda     #$e6
        ror
        sta     $6f
        sta     $06e2,y
        bne     @L51FE
L523E   lda     polyobj_xpos_lo,y
        asl
        sta     $7b
        lda     INWK+1,y
        rol
        sta     $7c
        lda     #$00
        ror
        sta     $7d
        jsr     L5378
        sta     INWK+2,x
        ldy     $7b
        sty     polyobj_xpos_lo,x
        ldy     $7c
        sty     INWK+1,x
        and     #$7f
        rts

L525F   lda     #$00
L5261   ora     data_buffer+2,y
        ora     data_buffer+5,y
        ora     data_buffer+8,y
        and     #$7f
        rts

L526D   lda     data_buffer+1,y
        jsr     L5F32
        sta     $ae
        lda     data_buffer+4,y
        jsr     L5F32
        adc     $ae
        bcs     @L528B
        sta     $ae
        lda     data_buffer+7,y
        jsr     L5F32
        adc     $ae
        bcc     @L528D
@L528B  lda     #$ff
@L528D  rts

L528E   lda     #$cd       ;"DOCKED"
        jsr     PrintDockedStr
        jsr     OutputFF
        jmp     L52D6

HiKillScore
        ldx     #$09       ;start at "Elite"
        cmp     #$19       ;>= $1900?
        bcs     PrintRating2 ;yes, done
        dex
        cmp     #$0a       ;>= $0a00?
        bcs     PrintRating2 ;yes, Deadly
        dex
        cmp     #$02       ;>= $0200?
        bcs     PrintRating2 ;yes, Dangerous
        dex                ;reduce to merely "Competent"
        bne     PrintRating2 ;(always)
ShipStatusScreen
        lda     #$08
        jsr     L6411
        jsr     L6A9E
        lda     #$07
        sta     text_hposn
        lda     #$7e       ;(multi-line commander / system / "condition:")
        jsr     PrintFlightTokLine
        lda     #$0f       ;?
        ldy     docked_flag
        bne     L528E
        lda     #$e6       ;"Green"
        ldy     PLAYER_STATE+42
        ldx     PLAYER_STATE+2,y
        beq     @L52D3
        ldy     $d6
        cpy     #$80
        adc     #$01       ;"Red"
@L52D3  jsr     PrintTokFF
L52D6   lda     #$7d       ;"$$$$$$.0 Cr Legal Status:"
        jsr     PrintTokSpc
        lda     #$13       ;"Clean"
        ldy     player_fug_inno
        beq     @L52E6
        cpy     #$32
        adc     #$01       ;"Offender"
@L52E6  jsr     PrintTokFF
        lda     #$10       ;"Rating:"
        jsr     PrintTokSpc
; Compute player rating.
        lda     kill_score+1 ;kill score >= 256?
        bne     HiKillScore ;yes, use different function
        tax                ;X-reg=0
        lda     kill_score ;set X-reg to log2(score)-2
        lsr                ;divide by 4
        lsr
@L52F9  inx                ;inc result until dividing by 2 yields zero
        lsr                ;$00-07=1, $08-0F=2, $10-$1f=3, etc.
        bne     @L52F9     ;Harmless to Competent
PrintRating2
        txa
        clc
        adc     #$15       ;"Harmless" - 1
        jsr     PrintTokFF
        lda     #$12       ;"EQUIPMENT:"
        jsr     PrintTokFFHposn
        lda     have_escape_pod
        beq     @L5313
        lda     #$70       ;"Escape Pod"
        jsr     PrintTokFFHposn
@L5313  lda     have_fuel_scoop
        beq     @L531D
        lda     #$6f       ;"Fuel Scoops"
        jsr     PrintTokFFHposn
@L531D  lda     have_ecm
        beq     @L5327
        lda     #$6c       ;"E.C.M. System"
        jsr     PrintTokFFHposn
@L5327  lda     #$71
        sta     $c0
@L532B  tay
        ldx     PLAYER_STATE+7,y
        beq     @L5334
        jsr     PrintTokFFHposn
@L5334  inc     $c0
        lda     $c0
        cmp     #$75
        bcc     @L532B
        ldx     #$00
@L533E  stx     $bd
        ldy     $029f,x
        beq     @L5368
        txa
        clc
        adc     #$60
        jsr     PrintTokSpc
        lda     #$67
        ldx     $bd
        ldy     $029f,x
        cpy     #$8f
        bne     @L5359
        lda     #$68
@L5359  cpy     #$97
        bne     @L535F
        lda     #$75
@L535F  cpy     #$32
        bne     @L5365
        lda     #$76
@L5365  jsr     PrintTokFFHposn
@L5368  ldx     $bd
        inx
        cpx     #$04
        bcc     @L533E
        rts

PrintTokFFHposn
        jsr     PrintTokFF
        lda     #$06
        sta     text_hposn
        rts

L5378   lda     $7d
        sta     $af
        and     #$80
        sta     $d0
        eor     INWK+2,x
        bmi     @L539C
        lda     $7b
        clc
        adc     polyobj_xpos_lo,x
        sta     $7b
        lda     $7c
        adc     INWK+1,x
        sta     $7c
        lda     $7d
        adc     INWK+2,x
        and     #$7f
        ora     $d0
        sta     $7d
        rts

@L539C  lda     $af
        and     #$7f
        sta     $af
        lda     polyobj_xpos_lo,x
        sec
        sbc     $7b
        sta     $7b
        lda     INWK+1,x
        sbc     $7c
        sta     $7c
        lda     INWK+2,x
        and     #$7f
        sbc     $af
        ora     #$80
        eor     $d0
        sta     $7d
        bcs     @L53D3
        lda     #$01
        sbc     $7b
        sta     $7b
        lda     #$00
        sbc     $7c
        sta     $7c
        lda     #$00
        sbc     $7d
        and     #$7f
        ora     $d0
        sta     $7d
@L53D3  rts

L53D4   lda     INWK+1,x
        and     #$7f
        lsr
        sta     $d0
        lda     polyobj_xpos_lo,x
        sec
        sbc     $d0
        sta     $ae
        lda     INWK+1,x
        sbc     #$00
        sta     $af
        lda     polyobj_xpos_lo,y
        sta     $31
        lda     INWK+1,y
        and     #$80
        sta     $d0
        lda     INWK+1,y
        and     #$7f
        lsr
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        ora     $d0
        eor     $c5
        stx     $ad
        jsr     ADD
        sta     $7b
        stx     $7a
        ldx     $ad
        lda     INWK+1,y
        and     #$7f
        lsr
        sta     $d0
        lda     polyobj_xpos_lo,y
        sec
        sbc     $d0
        sta     $ae
        lda     INWK+1,y
        sbc     #$00
        sta     $af
        lda     polyobj_xpos_lo,x
        sta     $31
        lda     INWK+1,x
        and     #$80
        sta     $d0
        lda     INWK+1,x
        and     #$7f
        lsr
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        ora     $d0
        eor     #$80
        eor     $c5
        stx     $ad
        jsr     ADD
        sta     INWK+1,y
        stx     polyobj_xpos_lo,y
        ldx     $ad
        lda     $7a
        sta     polyobj_xpos_lo,x
        lda     $7b
        sta     INWK+1,x
        rts

num_format_thing
        !hex    4876e800

PrintNumInX
        lda     #$03
L5466   ldy     #$00
L5468   sta     $ac
        lda     #$00
        sta     $7a
        sta     $7b
        sty     $7c
        stx     $7d
PrintNumber
        ldx     #$0b
        stx     $d0
        php
        bcc     @L547F
        dec     $d0
        dec     $ac
@L547F  lda     #$0b
        sec
        sta     $b2
        sbc     $ac
        sta     $ac
        inc     $ac
        ldy     #$00
        sty     $af
        jmp     @L54D0

@L5491  asl     $7d
        rol     $7c
        rol     $7b
        rol     $7a
        rol     $af
        ldx     #$03
@L549D  lda     $7a,x
        sta     $6e,x
        dex
        bpl     @L549D
        lda     $af
        sta     $72
        asl     $7d
        rol     $7c
        rol     $7b
        rol     $7a
        rol     $af
        asl     $7d
        rol     $7c
        rol     $7b
        rol     $7a
        rol     $af
        clc
        ldx     #$03
@L54BF  lda     $7a,x
        adc     $6e,x
        sta     $7a,x
        dex
        bpl     @L54BF
        lda     $72
        adc     $af
        sta     $af
        ldy     #$00
@L54D0  ldx     #$03
        sec
@L54D3  lda     $7a,x
        sbc     num_format_thing,x
        sta     $6e,x
        dex
        bpl     @L54D3
        lda     $af
        sbc     #$17
        sta     $72
        bcc     @L54F6
        ldx     #$03
@L54E7  lda     $6e,x
        sta     $7a,x
        dex
        bpl     @L54E7
        lda     $72
        sta     $af
        iny
        jmp     @L54D0

@L54F6  tya
        bne     @L5505
        lda     $d0
        beq     @L5505
        dec     $ac
        bpl     @L550F
        lda     #$20
        bne     @L550C

@L5505  ldy     #$00
        sty     $d0
        clc
        adc     #$30
@L550C  jsr     PrintChar
@L550F  dec     $d0
        bpl     @L5515
        inc     $d0
@L5515  dec     $b2
        bmi     @L5526
        bne     @L5523
        plp
        bcc     @L5523
        lda     #$2e
        jsr     PrintChar
@L5523  jmp     @L5491

@L5526  rts

text_ucase_mask
        !byte   $20
txt_lcase_flag
        !byte   $ff
txt_flight_flag
        !byte   $00
txt_buffer_flag
        !byte   $00
txt_buffer_index
        !byte   $00
text_ucase_flag
        !byte   $00
text_lcase_mask
        !byte   $ff
        !byte   $a9
        !byte   $0c
        !byte   $2c

PrintCharA
        lda     #'A'
; 
; Print a character.
; 
; On entry:
;   A-reg: ASCII value
; 
; 
        !zone   Z004b33
.saved_x =      $0a
PrintChar
        stx     .saved_x   ;preserve X-reg
        ldx     #$ff       ;disable lower-case transform
        stx     text_lcase_mask
        cmp     #'.'
        beq     @SetFlag
        cmp     #':'
        beq     @SetFlag
        cmp     #$0a       ;LF
        beq     @SetFlag
        cmp     #$0c       ;newline
        beq     @SetFlag
        cmp     #$20       ;space
        beq     @SetFlag
        inx                ;X=0, clearing flag
@SetFlag
        stx     txt_lcase_flag
        ldx     .saved_x
        bit     txt_buffer_flag ;using buffered printing?
        bmi     @Buffered  ;yes, write to buffer
        jmp     OutputChar ;no, output directly

@Buffered
        bit     txt_buffer_flag
        bvs     @L5565
        cmp     #$0c       ;newline?
        beq     @L5572
@L5565  ldx     txt_buffer_index
        sta     BUFFER_0100,x ;text buffer
        ldx     .saved_x
        inc     txt_buffer_index
        clc
        rts

@L5572  txa
        pha
        tya
        pha
@L5576  ldx     txt_buffer_index
        beq     @L55F3
        cpx     #$1f
        bcc     @L55F0
        lsr     $0b
@L5581  lda     $0b
        bmi     @L5589
        lda     #$40
        sta     $0b
@L5589  ldy     #$1d
@L558B  lda     $011e
        cmp     #$20
        beq     @L55BF
@L5592  dey
        bmi     @L5581
        beq     @L5581
        lda     BUFFER_0100,y
        cmp     #$20
        bne     @L5592
        asl     $0b
        bmi     @L5592
        sty     .saved_x
        ldy     txt_buffer_index
@L55A7  lda     BUFFER_0100,y
        sta     $0101,y
        dey
        cpy     .saved_x
        bcs     @L55A7
        inc     txt_buffer_index
@L55B5  cmp     BUFFER_0100,y
        bne     @L558B
        dey
        bpl     @L55B5
        bmi     @L5581

@L55BF  ldx     #$1e
        jsr     @L55E3
        lda     #$0c
        jsr     OutputChar
        lda     txt_buffer_index
        sbc     #$1e
        sta     txt_buffer_index
        tax
        beq     @L55F3
        ldy     #$00
        inx
@L55D7  lda     $011f,y
        sta     BUFFER_0100,y
        iny
        dex
        bne     @L55D7
        beq     @L5576

@L55E3  ldy     #$00
@L55E5  lda     BUFFER_0100,y
        jsr     OutputChar
        iny
        dex
        bne     @L55E5
        rts

@L55F0  jsr     @L55E3
@L55F3  stx     txt_buffer_index
        pla
        tay
        pla
        tax
        lda     #$0c
        !byte   $2c
PrintBell
        lda     #$07
        jmp     OutputChar

DrawHud ldy     #$00
        lda     #$d2
        sta     $7a
        ldx     #$14
        lda     $b6
        and     #$08
        and     ptb_kbd_flash
        beq     @L5615
        ldx     #$0c
@L5615  stx     $7c
        lda     player_speed
        jsr     @L5671
        lda     #$0c
        sta     $35
        lda     $6b
        lsr
        bit     $6d
        jsr     @L56C4
        lda     $67
        asl
        bit     $a7
        jsr     @L56C4
        lda     $d6
        lsr
@L5633  sta     $7b
        jsr     @L5671
        lda     $7b
        sec
        sbc     #$20
        bcs     @L5641
        lda     #$00
@L5641  cpy     #$07
        bne     @L5633
        lda     #$10
        sta     $7a
        lda     $d4
        jsr     @L566E
        lda     $d5
        jsr     @L566E
        lda     player_fuel
        jsr     @L5670
        lda     lcoord_swap_flag-1
        jsr     @L566E
        lda     PLAYER_STATE+46
        jsr     @L566E
        lda     player_laser_temp
        jsr     @L566E
        jmp     L7445

@L566E  lsr
        lsr
@L5670  lsr
@L5671  cmp     #$20
        bcc     @L5677
        lda     #$1f
@L5677  ldx     @L570A,y
        cmp     @L56FD,y
        bcc     @L5682
        ldx     @L5717,y
@L5682  cpx     #$ff
        bne     @L5689
        ldx     $7c
        clc
@L5689  iny
        pha
        cmp     L4543,y
        bne     @L5696
        txa
        cmp     $02de,y
        beq     @L56C2
@L5696  txa
        ldx     $02de,y
        sta     $02de,y
        lda     L4543,y
        jsr     @L56AA
        ldx     $02de,y
        pla
        sta     L4543,y
@L56AA  stx     $35
        ldx     @L56F0-1,y
        stx     $6f
        ldx     $7a
        stx     $6e
        clc
        adc     $7a
        and     #$fe
        sta     $70
        jsr     @L56BF
@L56BF  jmp     DrawDoubleHorizLine

@L56C2  pla
@L56C3  rts

@L56C4  bpl     @L56CB
        eor     #$ff
        clc
        adc     #$01
@L56CB  iny
        clc
        adc     #$e0
        cmp     L4543,y
        beq     @L56C3
        pha
        lda     L4543,y
        beq     @L56DD
        jsr     @L56E1
@L56DD  pla
        sta     L4543,y
@L56E1  sta     $6e
        lda     @L56F0-1,y
        sta     $6f
        clc
        adc     #$06
        sta     $71
        jmp     DrawVerticalLine

@L56F0  !byte   $89
        !byte   $90
        !byte   $98
        !xor    $80 {
        !text   "91)!"
        }
        !byte   $89
        !byte   $91
        !byte   $99
        !byte   $b1
        !byte   $a1
        !byte   $a9
@L56FD  !byte   $1c
        !byte   $00
        !byte   $00
        !byte   $10
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   $08
        !byte   $08
        !byte   $00
        !byte   $08
        !byte   $18
        !byte   $18
@L570A  !byte   $0c
        !byte   $0c
        !byte   $0c
        !byte   $ff
        !byte   $04
        !byte   $04
        !byte   $04
        !byte   $ff
        !byte   $ff
        !byte   $08
        !byte   $ff
        !byte   $10
        !byte   $10
@L5717  !byte   $ff
        !byte   $0c
        !byte   $0c
        !fill   6,$04
        !byte   $08
        !byte   $08
        !byte   $ff
        !byte   $ff

; BBC .ESCAPE "your Escape capsule launch"
EjectEscape
        jsr     RES2
        ldx     #11        ;Cobra Mk III
        stx     $b8
        jsr     FRS1
        bcs     @Es1
        ldx     #$18
        jsr     FRS1
@Es1    lda     #$08       ;"modest speed"
        sta     polyobj_vertex_lo
        lda     #$c2       ;"rotz, pitch counter"
        sta     polyobj_pitch
        lsr
        sta     polyobj_attack
@L5740  jsr     MVEIT
        jsr     DrawObject
        dec     polyobj_attack
        bne     @L5740
        jsr     SCAN
        lda     #$00       ;"zero-out cargo, including gems"
        ldx     #$10       ;"start at alien items"
@L5751  sta     player_cargo,x
        dex
        bpl     @L5751
        sta     player_fug_inno ;zero out fugitive status
        sta     have_escape_pod ;no more escape pod
        lda     #70        ;max fuel allowed = 70
        sta     player_fuel
        jmp     GOIN_jmp

L5765   lda     #$0e
        jsr     PrintDockedStr
        jsr     L6960
        jsr     L6A93
        lda     #$00
        sta     $c1
@L5774  jsr     SetBufferFlag
        jsr     PrintSelPlanet
        ldx     txt_buffer_index
        lda     INWK+5,x
        cmp     #$0d
        bne     @L5790
@L5783  dex
        lda     INWK+5,x
        ora     #$20
        cmp     BUFFER_0100,x
        beq     @L5783
        txa
        bmi     @L57A5
@L5790  jsr     L6418
        inc     $c1
        bne     @L5774
        jsr     L6A9E
        jsr     L6960
        jsr     Noise1
        lda     #$d7
        jmp     PrintDockedStr

@L57A5  lda     $95
        sta     $e0
        lda     $93
        sta     $e1
        jsr     L6A9E
        jsr     L6960
        jsr     ClearBufferFlag
        jmp     ShowDistToPlanet

L57B9   lda     polyobj_xpos_lo
        ora     polyobj_ypos_lo
        ora     polyobj_zpos_lo
        bne     @L57C6
        lda     #$50
        jsr     L74B4
@L57C6  ldx     #$04
        bne     L582B

; BBC .TA34 "Tactics, missile attacking player, from TA18"
L57CA   lda     #$00
        jsr     L7E20
        beq     @L57D4
        jmp     L5900

@L57D4  jsr     L582E
        jsr     MakeNoise2
        lda     #$fa
        jmp     L74B4

L57DF   lda     ecm_active_flag
        bne     L57B9
        lda     polyobj_attack
        asl
        bmi     L57CA
        lsr
        tax
        lda     L4E7E,x
        sta     $5e
        lda     L4E7F,x
        jsr     L5B15
        lda     $3a
        ora     $3d
        ora     $40
        and     #$7f
        ora     $39
        ora     $3c
        ora     $3f
        bne     L5834
        lda     polyobj_attack
        cmp     #$82
        beq     L57B9
        ldy     #$1f
        lda     ($5e),y
        bit     L583B+1
        bne     @L5818
        ora     #$80
        sta     ($5e),y
@L5818  lda     polyobj_xpos_lo
        ora     polyobj_ypos_lo
        ora     polyobj_zpos_lo
        bne     @L5825
        lda     #$50
        jsr     L74B4
@L5825  lda     polyobj_attack
        and     #$7f
        lsr
        tax
L582B   jsr     CountKill
L582E   asl     polyobj_vis
        sec
        ror     polyobj_vis
L5833   rts

L5834   jsr     GetRandom
        cmp     #$10
        bcs     L5842
L583B   ldy     #$20
        lda     ($5e),y
        lsr
        bcs     L5845
L5842   jmp     L5909

L5845   jmp     ActivateEcm

; BBC .TACTICS
TACTICS lda     #$03
        sta     $c4
        lda     #$04
        sta     $c5
        lda     #$16
        sta     $be
        cpx     #$01
        beq     L57DF
        cpx     #$02
        bne     L588A
        lda     $30
        and     #$04
        bne     @L5875
        lda     PLAYER_STATE+19
        bne     L5833
        jsr     GetRandom
        cmp     #$fd
        bcc     L5833
        and     #$01
        adc     #$08
        tax
        bne     L5885
@L5875  jsr     GetRandom
        cmp     #$f0
        bcc     L5833
        lda     PLAYER_STATE+25
        cmp     #$04
        bcs     L58C3
        ldx     #$10
L5885   lda     #$f1
        jmp     LaunchObject1

L588A   cpx     #$0f
        bne     @L58AA
        jsr     GetRandom
        cmp     #$c8
        bcc     L58C3
        ldx     #$00
        stx     polyobj_attack
        ldx     #$24
        stx     $30
        and     #$03
        adc     #$11
        tax
        jsr     L5885
        lda     #$00
        sta     polyobj_attack
        rts

@L58AA  ldy     #$0e
        lda     $2f
        cmp     (hull_ptr),y
        bcs     @L58B4
        inc     $2f
@L58B4  cpx     #$1e
        bne     L58C4
        lda     PLAYER_STATE+38
        bne     L58C4
        lsr     polyobj_attack
        asl     polyobj_attack
        lsr     polyobj_vertex_lo
L58C3   rts

L58C4   jsr     GetRandom
        lda     $30
        lsr
        bcc     @L58D0
        cpx     #$32
        bcs     L58C3
@L58D0  lsr
        bcc     @L58E2
        ldx     player_fug_inno
        cpx     #$28
        bcc     @L58E2
        lda     $30
        ora     #$04
        sta     $30
        lsr
        lsr
@L58E2  lsr
        bcs     L58F2
        lsr
        lsr
        bcc     L58EC
        jmp     L5A50

L58EC   jsr     L8274
        jmp     L5A40

L58F2   lsr
        bcc     L5900
        lda     PLAYER_STATE+11
        beq     L5900
        lda     polyobj_attack
        and     #$81
        sta     polyobj_attack
L5900   ldx     #$08
@L5902  lda     polyobj_xpos_lo,x
        sta     $38,x
        dex
        bpl     @L5902
L5909   jsr     L8283
        ldy     #$0a
        jsr     TAS3
        sta     $bd
        lda     $b8
        cmp     #$01
        bne     @L591C
        jmp     @L59DF

@L591C  cmp     #$0e
        bne     @L5935
        jsr     GetRandom
        cmp     #$c8
        bcc     @L5935
        jsr     GetRandom
        ldx     #$17
        cmp     #$64
        bcs     @L5932
        ldx     #$11
@L5932  jmp     L5885

@L5935  jsr     GetRandom
        cmp     #$fa
        bcc     @L5943
        jsr     GetRandom
        ora     #$68
        sta     polyobj_roll
@L5943  ldy     #$0e
        lda     (hull_ptr),y
        lsr
        cmp     $2f
        bcc     @L5998
        lsr
        lsr
        cmp     $2f
        bcc     @L5971
        jsr     GetRandom
        cmp     #$e6
        bcc     @L5971
        ldx     $b8
        lda     hull_NEWB-1,x ;has escape pod?
        bpl     @L5971     ;no
        lda     $30
        and     #$f0
        sta     $30
        ldy     #$24
        sta     (polyobj_ptr),y
        lda     #$00
        sta     polyobj_attack
        jmp     LaunchEscape

@L5971  lda     polyobj_vis
        and     #$07
        beq     @L5998
        sta     $d0
        jsr     GetRandom
        and     #$1f
        cmp     $d0
        bcs     @L5998
        lda     ecm_active_flag
        bne     @L5998
        dec     polyobj_vis
        lda     $b8        ;check ship type
        cmp     #29        ;Thargoid?
        bne     @NotThargoid
        ldx     #30        ;launch Thargon
        lda     polyobj_attack
        jmp     LaunchObject1

@NotThargoid
        jmp     LaunchMissile

; "Good energy > max/2"
@L5998  lda     #$00
        jsr     L7E20
        and     #$e0
        bne     @NoLaser
        ldx     $bd
        cpx     #$a0
        bcc     @NoLaser
        ldy     #$13       ;00LLLMMM laser/missile data for hull
        lda     (hull_ptr),y
        and     #$f8       ;keep laser power
        beq     @NoLaser
        lda     polyobj_vis
        ora     #$40       ;set bit 6 (laser firing at player)
        sta     polyobj_vis
        cpx     #$a3
        bcc     @NoLaser
        lda     (hull_ptr),y
        lsr
        jsr     L74B4
        dec     $28
        lda     ecm_active_flag
        bne     L5A2D
        jsr     MakeNoise5
@NoLaser
        lda     polyobj_zpos_mi
        cmp     #$03
        bcs     @L59D6
        lda     INWK+1
        ora     INWK+4
        and     #$fe
        beq     L59E8
@L59D6  jsr     GetRandom
        ora     #$80
        cmp     polyobj_attack
        bcs     L59E8
@L59DF  jsr     L5B69
        lda     $bd
        eor     #$80
L59E6   sta     $bd
L59E8   ldy     #$10
        jsr     TAS3
        tax
        eor     #$80
        and     #$80
        sta     polyobj_pitch
        txa
        asl
        cmp     $c5
        bcc     @L5A00
        lda     $c4
        ora     polyobj_pitch
        sta     polyobj_pitch
@L5A00  lda     polyobj_roll
        asl
        cmp     #$20
        bcs     @L5A21
        ldy     #$16
        jsr     TAS3
        tax
        eor     polyobj_pitch
        and     #$80
        eor     #$80
        sta     polyobj_roll
        txa
        asl
        cmp     $c5
        bcc     @L5A21
        lda     $c4
        ora     polyobj_roll
        sta     polyobj_roll
@L5A21  lda     $bd
        bmi     L5A2E
        cmp     $be
        bcc     L5A2E
        lda     #$03
        sta     $28
L5A2D   rts

L5A2E   and     #$7f
        cmp     #$12
        bcc     @L5A3F
        lda     #$ff
        ldx     $b8
        cpx     #$01
        bne     @L5A3D
        asl
@L5A3D  sta     $28
@L5A3F  rts

L5A40   ldy     #$0a
        jsr     TAS3
        cmp     #$98
        bcc     @L5A4D
        ldx     #$00
        stx     $c5
@L5A4D  jmp     L59E6

L5A50   lda     #$06
        sta     $c5
        lsr
        sta     $c4
        lda     #$1d
        sta     $be
        lda     PLAYER_STATE+11
        bne     @L5A63
@L5A60  jmp     L58EC

@L5A63  jsr     @L5B0F
        lda     $3a
        ora     $3d
        ora     $40
        and     #$7f
        bne     @L5A60
        jsr     L82A6
        lda     $ad
        sta     $7a
        jsr     L8283
        ldy     #$0a
        jsr     L5B47
        bmi     @L5AA6
        cmp     #$23
        bcc     @L5AA6
        ldy     #$0a
        jsr     TAS3
        cmp     #$a2
        bcs     @L5AC0
        lda     $7a
        cmp     #$9d
        bcc     @L5A98
        lda     $b8
        bmi     @L5AC0
@L5A98  jsr     L5B69
        jsr     L5A40
@L5A9E  ldx     #$00
        stx     $28
        inx
        stx     polyobj_vertex_lo
        rts

@L5AA6  jsr     @L5B0F
        jsr     L5B7C
        jsr     L5B7C
        jsr     L8283
        jsr     L5B69
        jmp     L5A40

@L5AB8  inc     $28
        lda     #$7f
        sta     polyobj_roll
        bne     @L5B05

@L5AC0  ldx     #$00
        stx     $c5
        stx     polyobj_pitch
        lda     $b8
        bpl     @L5AEA
        eor     $6e
        eor     $6f
        asl
        lda     #$02
        ror
        sta     polyobj_roll
        lda     $6e
        asl
        cmp     #$0c
        bcs     @L5A9E
        lda     $6f
        asl
        lda     #$02
        ror
        sta     polyobj_pitch
        lda     $6f
        asl
        cmp     #$0c
        bcs     @L5A9E
@L5AEA  stx     polyobj_roll
        lda     $22
        sta     $6e
        lda     $24
        sta     $6f
        lda     $26
        sta     $70
        ldy     #$10
        jsr     L5B47
        asl
        cmp     #$42
        bcs     @L5AB8
        jsr     @L5A9E
@L5B05  lda     $42
        bne     @L5B0E
        asl     $30
        sec
        ror     $30
@L5B0E  rts

@L5B0F  lda     #$25
        sta     $5e
        lda     #$08
L5B15   sta     $5f
        ldy     #$02
        jsr     @L5B23
        ldy     #$05
        jsr     @L5B23
        ldy     #$08
@L5B23  lda     ($5e),y
        eor     #$80
        sta     $7d
        dey
        lda     ($5e),y
        sta     $7c
        dey
        lda     ($5e),y
        sta     $7b
        sty     $ac
        ldx     $ac
        jsr     L5378
        ldy     $ac
        sta     $3a,x
        lda     $7c
        sta     $39,x
        lda     $7b
        sta     $38,x
        rts

L5B47   ldx     data_buffer+37,y
        stx     $ad
        lda     $6e
        jsr     MULT12
        ldx     data_buffer+39,y
        stx     $ad
        lda     $6f
        jsr     MAD
        sta     $af
        stx     $ae
        ldx     data_buffer+41,y
        stx     $ad
        lda     $70
        jmp     MAD

L5B69   lda     $6e
        eor     #$80
        sta     $6e
        lda     $6f
        eor     #$80
        sta     $6f
        lda     $70
        eor     #$80
        sta     $70
        rts

L5B7C   jsr     @L5B7F
@L5B7F  lda     data_buffer+47
        ldx     #$00
        jsr     @L5B94
        lda     data_buffer+49
        ldx     #$03
        jsr     @L5B94
        lda     data_buffer+51
        ldx     #$06
@L5B94  asl
        sta     $ae
        lda     #$00
        ror
        eor     #$80
        eor     $3a,x
        bmi     @L5BAB
        lda     $ae
        adc     $38,x
        sta     $38,x
        bcc     @L5BAA
        inc     $39,x
@L5BAA  rts

@L5BAB  lda     $38,x
        sec
        sbc     $ae
        sta     $38,x
        lda     $39,x
        sbc     #$00
        sta     $39,x
        bcs     @L5BAA
        lda     $38,x
        eor     #$ff
        adc     #$01
        sta     $38,x
        lda     $39,x
        eor     #$ff
        adc     #$00
        sta     $39,x
        lda     $3a,x
        eor     #$80
        sta     $3a,x
        jmp     @L5BAA

L5BD3   clc
        lda     polyobj_zpos_hi
        bne     L5C11
        lda     $b8
        bmi     L5C11
        lda     polyobj_vis
        and     #$20
        ora     INWK+1
        ora     INWK+4
        bne     L5C11
        lda     polyobj_xpos_lo
        jsr     L5F32
        sta     $af
        lda     $31
        sta     $ae
        lda     polyobj_ypos_lo
        jsr     L5F32
        tax
        lda     $31
        adc     $ae
        sta     $ae
        txa
        adc     $af
        bcs     L5C12
        sta     $af
        ldy     #$02
        lda     (hull_ptr),y
        cmp     $af
        bne     L5C11
        dey
        lda     (hull_ptr),y
        cmp     $ae
L5C11   rts

L5C12   clc
        rts

; BBC .FRS1 "escape capsule Launched, see Cobra Mk3 ahead, or player missile
; launch."
FRS1    jsr     ZeroInfo
        lda     #$1c
        sta     polyobj_ypos_lo
        lsr
        sta     polyobj_zpos_lo
        lda     #$80
        sta     INWK+5
        lda     missile_thing
        asl
        ora     #$80
        sta     polyobj_attack
L5C29   lda     #$60
        sta     polyobj_mox2_hi
        ora     #$80
        sta     $22
        lda     player_speed
        rol
        sta     polyobj_vertex_lo
        txa
        jmp     L7545

L5C3A   ldx     #$01
        jsr     FRS1
        bcc     PrintMslJammed
        ldx     missile_thing
        jsr     GetInfo
        lda     PLAYER_STATE,x
        jsr     L5C59
        ldy     #$00
        jsr     L75E6
        dec     missile_armed_flag
        ldy     #$78
        jsr     MakeNoise1
L5C59   cmp     #$02
        beq     @L5C8C
        ldy     #$24
        lda     (polyobj_ptr),y
        and     #$20
        beq     @L5C68
        jsr     @L5C8C
@L5C68  ldy     #$20
        lda     (polyobj_ptr),y
        beq     L5C11
        ora     #$80
        sta     (polyobj_ptr),y
        ldy     #$1c
        lda     #$02
        sta     (polyobj_ptr),y
        asl
        ldy     #$1e
        sta     (polyobj_ptr),y
        lda     $b8
        cmp     #$0b
        bcc     @L5C8B
        ldy     #$24
        lda     (polyobj_ptr),y
        ora     #$04
        sta     (polyobj_ptr),y
@L5C8B  rts

@L5C8C  lda     data_buffer+73
        ora     #$04
        sta     data_buffer+73
        rts

PrintMslJammed
        lda     #$c9       ;"Missile Jammed"
        jmp     PrintMessageBriefly

LaunchEscape
        ldx     #3         ;Escape Capsule
LaunchObject
        lda     #$fe
LaunchObject1
        sta     $06
        txa                ;X-reg = ship type (e.g. #30 = Thargon)
        pha
        lda     hull_ptr
        pha
        lda     hull_ptr+1
        pha
        lda     polyobj_ptr
        pha
        lda     polyobj_ptr+1
        pha
        ldy     #$24
@L5CB0  lda     polyobj_xpos_lo,y
        sta     BUFFER_0100,y
        lda     (polyobj_ptr),y
        sta     polyobj_xpos_lo,y
        dey
        bpl     @L5CB0
        lda     $b8
        cmp     #$02
        bne     @L5CE1
        txa
        pha
        lda     #$20
        sta     polyobj_vertex_lo
        ldx     #$00
        lda     $16
        jsr     @L5D20
        ldx     #$03
        lda     $18
        jsr     @L5D20
        ldx     #$06
        lda     polyobj_mox2_hi
        jsr     @L5D20
        pla
        tax
@L5CE1  lda     $06
        sta     polyobj_attack
        lsr     polyobj_roll
        asl     polyobj_roll
        txa
        cmp     #$09
        bcs     @L5D04
        cmp     #$04
        bcc     @L5D04
        pha
        jsr     GetRandom
        asl
        sta     polyobj_pitch
        txa
        and     #$0f
        sta     polyobj_vertex_lo
        lda     #$ff
        ror
        sta     polyobj_roll
        pla
@L5D04  jsr     L7545
        pla
        sta     polyobj_ptr+1
        pla
        sta     polyobj_ptr
        ldx     #$24
@L5D0F  lda     BUFFER_0100,x
        sta     polyobj_xpos_lo,x
        dex
        bpl     @L5D0F
        pla
        sta     hull_ptr+1
        pla
        sta     hull_ptr
        pla
        tax
        rts

@L5D20  asl
        sta     $ae
        lda     #$00
        ror
        jmp     L920A

L5D29   lda     #$ff
@Loop   sta     $07
        tax
        ldy     #$5a
        jsr     MakeNoise4
        lda     $07
        sbc     #$0a
        cmp     #$aa
        bcs     @Loop
        lda     #$04
        jsr     DrawRing
        rts

; 
; Draws the octagon ring animation for dock / undock.
; 
DrawOctagonRings
        ldy     #$00
        jsr     MakeNoise1
        jsr     MakeNoise1
        lda     #$08       ;octagon rings
DrawRing
        sta     $bf
        lda     displayed_screen
        pha
        lda     #$00
        jsr     PrintFlightHud
        pla
        sta     displayed_screen
L5D58   ldx     #$80
        stx     $38
        ldx     #$44
        stx     $46
        ldx     #$00
        stx     $c0
        stx     $39
        stx     $47
@RingLoop
        jsr     @DrawOneRing
        inc     $c0
        ldx     $c0
        cpx     #$08
        bne     @RingLoop
        rts

@DrawOneRing
        lda     $c0
        and     #$07
        clc
        adc     #$08
        sta     $7a
@L5D7D  ldy     #$0a
        jsr     MakeNoise1
        lda     #$01
        sta     $91
        jsr     L77BA
        asl     $7a
        bcs     @Return
        lda     $7a
        cmp     #$a0
        bcc     @L5D7D
@Return rts

L5D94   lda     #$00
        cpx     #$02
        ror
        sta     $c4
        eor     #$80
        sta     $c5
        jsr     @L5E4D
        ldy     $e2
@L5DA4  lda     SCRNHOLE5+4,y
        sta     $b4
        lsr
        lsr
        lsr
        jsr     L60CA
        lda     $31
        sta     $cf
        eor     $c5
        sta     $af
        lda     $06d5,y
        sta     $31
        lda     $06c8,y
        sta     $6e
        jsr     ADD
        sta     $af
        stx     $ae
        lda     $06e2,y
        sta     $6f
        eor     $a7
        ldx     $67
        jsr     MULTS
        jsr     ADD
        stx     $60
        sta     $61
        ldx     $06ef,y
        stx     $ae
        ldx     $6f
        stx     $af
        ldx     $67
        eor     $a8
        jsr     MULTS
        jsr     ADD
        stx     $62
        sta     $63
        ldx     $6b
        eor     $6c
        jsr     MULTS
        sta     $ad
        lda     $60
        sta     $ae
        lda     $61
        sta     $af
        eor     #$80
        jsr     MAD
        sta     $61
        txa
        sta     $06d5,y
        lda     $62
        sta     $ae
        lda     $63
        sta     $af
        jsr     MAD
        sta     $af
        stx     $ae
        lda     #$00
        sta     $31
        lda     $b9
        jsr     L4ED3
        lda     $61
        sta     $06c8,y
        sta     $6e
        and     #$7f
        eor     #$7f
        cmp     $cf
        bcc     @L5E68
        beq     @L5E68
        lda     $63
        sta     $06e2,y
        sta     $6f
        and     #$7f
        cmp     #$74
        bcs     @L5E7B
@L5E44  jsr     L4EDC
        dey
        beq     @L5E4D
        jmp     @L5DA4

@L5E4D  lda     $b9
        eor     $c4
        sta     $b9
        lda     $6c
        eor     $c4
        sta     $6c
        eor     #$80
        sta     $6d
        lda     $a7
        eor     $c4
        sta     $a7
        eor     #$80
        sta     $a8
        rts

@L5E68  jsr     GetRandom
        sta     $6f
        sta     $06e2,y
        lda     #$73
        ora     $c4
        sta     $6e
        sta     $06c8,y
        bne     @L5E8C
@L5E7B  jsr     GetRandom
        sta     $6e
        sta     $06c8,y
        lda     #$6e
        ora     $6d
        sta     $6f
        sta     $06e2,y
@L5E8C  jsr     GetRandom
        ora     #$08
        sta     $b4
        sta     SCRNHOLE5+4,y
        bne     @L5E44

L5E98   sta     $7a
        sta     $7b
        sta     $7c
        sta     $7d
        clc
        rts

L5EA2   sta     $ae
        and     #$7f
        sta     $7c
        lda     $ad
        and     #$7f
        beq     L5E98
        sec
        sbc     #$01
        sta     $d0
        lda     $32
        lsr     $7c
        ror
        sta     $7b
        lda     $31
        ror
        sta     $7a
        lda     #$00
        ldx     #$18
@L5EC3  bcc     @L5EC7
        adc     $d0
@L5EC7  ror
        ror     $7c
        ror     $7b
        ror     $7a
        dex
        bne     @L5EC3
        sta     $d0
        lda     $ae
        eor     $ad
        and     #$80
        ora     $d0
        sta     $7d
        rts

; ".MLS2 &27BE assign from stars R.S = XX(0to1), and P.A = A.alp1 (alp1+<32)"
MLS2    ldx     $60
        stx     $ae
        ldx     $61
        stx     $af
MLS1    ldx     $6b
; ".MULTS &27CA P.A =A*P(P+<32)"
MULTS   stx     $31
        tax
        and     #$80
        sta     $d0
        txa
        and     #$7f
        beq     @L5F2B
        tax
        dex
        stx     $06
        lda     #$00
        lsr     $31
        bcc     @L5F00
        adc     $06
@L5F00  ror
        ror     $31
        bcc     @L5F07
        adc     $06
@L5F07  ror
        ror     $31
        bcc     @L5F0E
        adc     $06
@L5F0E  ror
        ror     $31
        bcc     @L5F15
        adc     $06
@L5F15  ror
        ror     $31
        bcc     @L5F1C
        adc     $06
@L5F1C  ror
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        lsr
        ror     $31
        ora     $d0
        rts

@L5F2B  sta     $32
        sta     $31
        rts

L5F30   and     #$7f
L5F32   sta     $31
        tax
        bne     L5F49
L5F37   clc
        stx     $31
        txa
        rts

L5F3C   lda     $06e2,y
        sta     $6f
L5F41   and     #$7f
        sta     $31
L5F45   ldx     $ad
        beq     L5F37
L5F49   dex
        stx     $d0
        lda     #$00
        tax
        lsr     $31
        bcc     @L5F55
        adc     $d0
@L5F55  ror
        ror     $31
        bcc     @L5F5C
        adc     $d0
@L5F5C  ror
        ror     $31
        bcc     @L5F63
        adc     $d0
@L5F63  ror
        ror     $31
        bcc     @L5F6A
        adc     $d0
@L5F6A  ror
        ror     $31
        bcc     @L5F71
        adc     $d0
@L5F71  ror
        ror     $31
        bcc     @L5F78
        adc     $d0
@L5F78  ror
        ror     $31
        bcc     @L5F7F
        adc     $d0
@L5F7F  ror
        ror     $31
        bcc     @L5F86
        adc     $d0
@L5F86  ror
        ror     $31
        rts

; ".FMLTU2 &283D for CIRCLE2, A=K*sin(X)/256unsg"
FMLTU2  and     #$1f
        tax
        lda     sine_table,x
        sta     $ad
        lda     $7a
; ".FMLTU &2847 A=A*Q/256unsg fast multiply"
FMLTU   stx     $31
        sta     $ca
        tax
        beq     @L5FB9
        lda     math_table2,x
        ldx     $ad
        beq     @L5FB7
        clc
        adc     math_table2,x
        lda     math_table1,x
        ldx     $ca
        adc     math_table1,x
        bcc     @L5FB7
        tax
        lda     math_table3,x
        ldx     $31
        rts

@L5FB7  lda     #$00
@L5FB9  ldx     $31
        rts

; ".MLTU  AP(2)= AP* Xunsg(EOR P)"
MLTU2   stx     $ad
MLTU2_2 eor     #$ff
        lsr
        sta     $32
        lda     #$00
        ldx     #$10
        ror     $31
@L5FC9  bcs     @MU21
        adc     $ad
        ror
        ror     $32
        ror     $31
        dex
        bne     @L5FC9
        rts

@MU21   lsr
        ror     $32
        ror     $31
        dex
        bne     @L5FC9
        rts

unref_MUT3
        ldx     $6b
        stx     $31
MUT2    ldx     $61
        stx     $af
MUT1    ldx     $60
        stx     $ae
MULT1   tax
        and     #$7f
        lsr
        sta     $31
        txa
        eor     $ad
        and     #$80
        sta     $d0
        lda     $ad
        and     #$7f
        beq     @L603C
        tax
        dex
        stx     $06
        lda     #$00
        tax
        bcc     @L6009
        adc     $06
@L6009  ror
        ror     $31
        bcc     @L6010
        adc     $06
@L6010  ror
        ror     $31
        bcc     @L6017
        adc     $06
@L6017  ror
        ror     $31
        bcc     @L601E
        adc     $06
@L601E  ror
        ror     $31
        bcc     @L6025
        adc     $06
@L6025  ror
        ror     $31
        bcc     @L602C
        adc     $06
@L602C  ror
        ror     $31
        bcc     @L6033
        adc     $06
@L6033  ror
        ror     $31
        lsr
        ror     $31
        ora     $d0
        rts

@L603C  sta     $31
        rts

; ".MULT12 &28D4  R.S = Q * A   visited quite often"
MULT12  jsr     MULT1
        sta     $af
        lda     $31
        sta     $ae
        rts

TAS3    ldx     polyobj_xpos_lo,y
        stx     $ad
        lda     $6e
        jsr     MULT12
        ldx     INWK+2,y
        stx     $ad
        lda     $6f
        jsr     MAD
        sta     $af
        stx     $ae
        ldx     INWK+4,y
        stx     $ad
        lda     $70
; ".MAD &28FC  Multiply and Add  X.A = Q*A + R.S"
MAD     jsr     MULT1
; ".ADD &28FF  X.A = P.A + R.S"
ADD     sta     $06
        and     #$80
        sta     $d0
        eor     $af
        bmi     MU8
        lda     $ae
        clc
        adc     $31
        tax
        lda     $af
        adc     $06
        ora     $d0
        rts

MU8     lda     $af
        and     #$7f
        sta     $ac
        lda     $31
        sec
        sbc     $ae
        tax
        lda     $06
        and     #$7f
        sbc     $ac
        bcs     @MU9
        sta     $ac
        txa
        eor     #$ff
        adc     #$01
        tax
        lda     #$00
        sbc     $ac
        ora     #$80
@MU9    eor     $d0
        rts

TIS1    stx     $ad
        eor     #$80
        jsr     MAD
        tax
        and     #$80
        sta     $d0
        txa
        and     #$7f
        ldx     #$fe
        stx     $06
DVL3    asl
        cmp     #$60
        bcc     DV4
        sbc     #$60
DV4     rol     $06
        bcs     DVL3
        lda     $06
        ora     $d0
        rts

; ".DV42 &295E  travel step of dust particle front/rear"
DV42    lda     SCRNHOLE5+4,y
L60CA   sta     $ad
        lda     player_speed
L60CE   asl
        sta     $31
        lda     #$00
        rol
        cmp     $ad
        bcc     @L60DA
        sbc     $ad
@L60DA  rol     $31
        rol
        cmp     $ad
        bcc     @L60E3
        sbc     $ad
@L60E3  rol     $31
        rol
        cmp     $ad
        bcc     @L60EC
        sbc     $ad
@L60EC  rol     $31
        rol
        cmp     $ad
        bcc     @L60F5
        sbc     $ad
@L60F5  rol     $31
        rol
        cmp     $ad
        bcc     @L60FE
        sbc     $ad
@L60FE  rol     $31
        rol
        cmp     $ad
        bcc     @L6107
        sbc     $ad
@L6107  rol     $31
        rol
        cmp     $ad
        bcc     @L6110
        sbc     $ad
@L6110  rol     $31
        rol
        cmp     $ad
        bcc     @L6119
        sbc     $ad
@L6119  rol     $31
        ldx     #$00
        sta     $ca
        tax
        beq     @L613B
        lda     math_table2,x
        ldx     $ad
        sec
        sbc     math_table2,x
        ldx     $ca
        lda     math_table1,x
        ldx     $ad
        sbc     math_table1,x
        bcs     @L613E
        tax
        lda     math_table3,x
@L613B  sta     $ae
        rts

@L613E  lda     #$ff
        sta     $ae
        rts

L6143   sta     $33
        lda     polyobj_zpos_lo
        ora     #$01
        sta     $ad
        lda     polyobj_zpos_mi
        sta     $ae
        lda     polyobj_zpos_hi
        sta     $af
        lda     $31
        ora     #$01
        sta     $31
        lda     $33
        eor     $af
        and     #$80
        sta     $d0
        ldy     #$00
        lda     $33
        and     #$7f
@L6167  cmp     #$40
        bcs     @L6173
        asl     $31
        rol     $32
        rol
        iny
        bne     @L6167
@L6173  sta     $33
        lda     $af
        and     #$7f
@L6179  dey
        asl     $ad
        rol     $ae
        rol
        bpl     @L6179
        sta     $ad
        lda     #$fe
        sta     $ae
        lda     $33
@L6189  asl
        bcs     @L6199
        cmp     $ad
        bcc     @L6192
        sbc     $ad
@L6192  rol     $ae
        bcs     @L6189
        jmp     @L61A2

@L6199  sbc     $ad
        sec
        rol     $ae
        bcs     @L6189
        lda     $ae
@L61A2  lda     #$00
        sta     $7b
        sta     $7c
        sta     $7d
        tya
        bpl     @L61CB
        lda     $ae
@L61AF  asl
        rol     $7b
        rol     $7c
        rol     $7d
        iny
        bne     @L61AF
        sta     $7a
        lda     $7d
        ora     $d0
        sta     $7d
        rts

@L61C2  lda     $ae
        sta     $7a
        lda     $d0
        sta     $7d
        rts

@L61CB  beq     @L61C2
        lda     $ae
@L61CF  lsr
        dey
        bne     @L61CF
        sta     $7a
        lda     $d0
        sta     $7d
        rts

; ".cntr &29FF  center ship indicators"
L61DA   lda     computer_dock_flag
        bne     @L61E4
        lda     ptb_kbd_dampening
        bne     L61F0
@L61E4  txa
        bpl     @L61EA
        dex
        bmi     L61F0
@L61EA  inx
        bne     L61F0
        dex
        beq     @L61EA
L61F0   rts

L61F1   sta     $d0
        txa
        clc
        adc     $d0
        tax
        bcc     @L61FC
        ldx     #$ff
@L61FC  bpl     L620E
L61FE   lda     $d0
        rts

REDU2   sta     $d0
        txa
        sec
        sbc     $d0
        tax
        bcs     @L620C
        ldx     #$01
@L620C  bpl     L61FE
L620E   lda     ptb_kbd_recent
        bne     L61FE
        ldx     #$80
        bmi     L61FE

L6217   jsr     GetRandom
        and     #$07
        adc     #$40
        sta     $027a
        jsr     GetRandom
        and     #$07
        adc     #$7c
        sta     $0279
        lda     player_laser_temp
        adc     #$08
        sta     player_laser_temp
        jsr     L743C
L6236   lda     displayed_screen
        bne     L61F0
        lda     #$20
        ldy     #$e0
        jsr     @L6245
        lda     #$30
        ldy     #$d0
@L6245  sta     $70
        lda     $0279
        sta     $6e
        lda     $027a
        sta     $6f
        lda     #$87
        sta     $71
        jsr     DrawLine
        lda     $0279
        sta     $6e
        lda     $027a
        sta     $6f
        sty     $70
        lda     #$87
        sta     $71
        jmp     DrawLine

L626B   lda     $de
        ora     $df
        bne     @L62A9
        lda     docked_flag
        bpl     @L62A9
        ldy     #$00
@L6277  lda     text_stuff1-1,y
        cmp     $b4
        bne     @L62A6
        lda     text_stuff2,y
        and     #$7f
        cmp     ship_state2
        bne     @L62A6
        lda     text_stuff2,y
        bmi     @L6299
        lda     $028f
        lsr
        bcc     @L62A9
        jsr     SetBufferFlag
        lda     #$01
        !byte   $2c
@L6299  lda     #$b0       ;0d 0e 13: set ucase flags; turn buffering on; ?
        jsr     PrintDockedToken
        tya
        jsr     PrintExtDockedStr
        lda     #$b1       ;. [ff], turn buffering off
        bne     @PrintStr

@L62A6  dey
        bne     @L6277
@L62A9  ldx     #$03
@L62AB  lda     $94,x
        sta     rng_state,x
        dex
        bpl     @L62AB
        lda     #$05
@PrintStr
        jmp     PrintDockedStr ;buffered: <thing> IS <thing>.

L62B7   lda     $028f
        ora     #$04
        sta     $028f
        lda     #$0b
L62C1   jsr     PrintDockedStr
        jmp     L7F2D

L62C7   lda     $028f
        and     #$f0
        ora     #$0a
        sta     $028f
        lda     #$de
        bne     L62C1

L62D5   lda     $028f
        ora     #$04
        sta     $028f
        lda     #$02
        sta     have_energy_unit
        inc     kill_score+1
        lda     #$df
        bne     L62C1

L62E9   lsr     $028f
        asl     $028f
        ldx     #$50
        ldy     #$c3
        jsr     AddCredits
        lda     #$0f
L62F8   bne     L62C1

L62FA   lsr     $028f
        sec
        rol     $028f
        jsr     PrintIncomingMessage
        jsr     ZeroInfo
        lda     #$1f
        sta     $b8
        jsr     L7545
        lda     #$01
        sta     text_hposn
        sta     polyobj_zpos_mi
        lda     #$0d
        jsr     PrintFlightHud
        lda     #$40
        sta     $b6
@L631D  ldx     #$7f
        stx     polyobj_roll
        stx     polyobj_pitch
        jsr     DrawObject
        jsr     MVEIT
        dec     $b6
        bne     @L631D
@L632D  lsr     polyobj_xpos_lo
        inc     polyobj_zpos_lo
        beq     @L634D
        inc     polyobj_zpos_lo
        beq     @L634D
        ldx     polyobj_ypos_lo
        inx
        cpx     #$50
        bcc     @L6340
        ldx     #$50
@L6340  stx     polyobj_ypos_lo
        jsr     DrawObject
        jsr     MVEIT
        dec     $b6
        jmp     @L632D

@L634D  inc     polyobj_zpos_mi
        jsr     L6363
        lda     #$0a
        bne     L62F8

PrintIncomingMessage
        lda     #$d8
        jsr     PrintDockedStr
        ldy     #$64
        jmp     LongDelay

WaitKeyDrawHud
        jsr     WaitForKey
L6363   lda     #$01
        jmp     PrintFlightHud

Vposn9_SetMask
        lda     #$09
        !byte   $2c
Vposn5_SetMask
        lda     #$05
        sta     text_vposn
        jmp     SetUpperMask

; 
; Wait until a key is hit.  Pending input will be discarded.
; 
; On exit:
;   A-reg: key hit
;   (commands set as well)
; 
WaitForKey
        jsr     CheckForInput ;check for pending input
        bne     WaitForKey ;if key available, discard and retry
        jsr     CheckForInput ;check for pending input
        beq     WaitForKey ;wait until one is available
        rts

GetInfo txa
        asl
        tay
        lda     L4E7E,y
        sta     polyobj_ptr
        lda     L4E7F,y
        sta     polyobj_ptr+1
        rts

L638B   ldx     #$01
@L638D  lda     $0290,x
        sta     $e0,x
        dex
        bpl     @L638D
        rts

LongDelay
        jsr     Delay
        dey
        bne     LongDelay
        rts

planet_desc_adj
        !hex    10151a1f9ba02ea524293d3338aa42474c51568c606587825b6ab4b9bee1e6eb
        !hex    f0f5fa73787d

L63C3   lsr
L63C4   sta     $08
        lsr
        lsr
        sec
        sbc     $08
        eor     #$ff
        adc     #$01
        rts

L63D0   jsr     L63C4
        adc     #$20
        rts

L63D6   sta     $6e
        lda     #$13
        sta     $6f
        lda     #$73
        sta     $71
        jmp     DrawVerticalLine

L63E3   sta     $02f0
        lda     #$01
L63E8   pha
        ldx     #$0c
        cpx     $02f0
        bcc     @L63FE
@L63F0  adc     player_cargo,x
        dex
        bpl     @L63F0
        adc     kill_score_rem-1
        cmp     cargo_capacity
        pla
        rts

@L63FE  ldy     $02f0
        adc     player_cargo,y
        cmp     #$c8
        pla
        rts

L6408   sta     text_hposn
        rts

L640B   sta     text_vposn
        rts

IncTextVposn
        inc     text_vposn
        rts

L6411   jsr     PrintFlightHud
        jmp     ClearKbdStrb

        !byte   $60

L6418   jsr     @L641B
@L641B  jsr     L641E
L641E   lda     $92
        clc
        adc     $94
        tax
        lda     $93
        adc     $95
        tay
        lda     $94
        sta     $92
        lda     $95
        sta     $93
        lda     $97
        sta     $95
        lda     $96
        sta     $94
        clc
        txa
        adc     $94
        sta     $96
        tya
        adc     $95
        sta     $97
        rts

L6445   lda     $de
        ora     $df
        bne     @L644E
        inc     text_vposn
        rts

@L644E  lda     #$bf       ;"Distance"
        jsr     PrintFlightTokCol
        ldx     $de
        ldy     $df
        sec
        jsr     Print4XloYhi
        lda     #$c3       ;"Light Years"
PrintFlightTokNL
        jsr     PrintFlightToken
IncTextVpos1
        inc     text_vposn
L6462   lda     #$80
        sta     text_mod_flags
PrintFF lda     #$0c       ;newline (technically form feed)
        jmp     PrintFlightToken

L646B   lda     #$ad       ;"Mainly"
        jsr     PrintFlightToken
        jmp     L64A9

PrintTokSpc
        jsr     PrintFlightToken
        jmp     PrintSpace

; 
; Planetary information screen.
; 
SystemDataScreen
        lda     #$01
        jsr     L6411
        lda     #$09
        jsr     L6408
        lda     #$a3
        jsr     PrintFlightTokLine
        jsr     IncTextVpos1
        jsr     L6445
        lda     #$c2       ;"Economy"
        jsr     PrintFlightTokCol
        lda     $d7
        clc
        adc     #$01
        lsr
        cmp     #$02
        beq     L646B
        lda     $d7
        bcc     @L64A4
        sbc     #$05
        clc
@L64A4  adc     #$aa       ;"Rich"
        jsr     PrintFlightToken
L64A9   lda     $d7
        lsr
        lsr
        clc
        adc     #$a8
        jsr     PrintFlightTokNL
        lda     #$a2       ;"Government"
        jsr     PrintFlightTokCol
        lda     $d8
        clc
        adc     #$b1
        jsr     PrintFlightTokNL
        lda     #$c4       ;"Tech Level"
        jsr     PrintFlightTokCol
        ldx     $d9
        inx
        clc
        jsr     PrintNumInX
        jsr     IncTextVpos1
        lda     #$c0       ;"Population"
        jsr     PrintFlightTokCol
        sec
        ldx     $da
        jsr     PrintNumInX
        lda     #$c6
        jsr     PrintFlightTokNL
        lda     #$28       ;"("
        jsr     PrintFlightToken
        lda     $96
        bmi     @L64F0
        lda     #$bc       ;"Human Colonial"
        jsr     PrintFlightToken
        jmp     @L652C

@L64F0  lda     $97
        lsr
        lsr
        pha
        and     #$07
        cmp     #$03
        bcs     @L6500
        adc     #$e3
        jsr     PrintTokSpc
@L6500  pla
        lsr
        lsr
        lsr
        cmp     #$06
        bcs     @L650D
        adc     #$e6
        jsr     PrintTokSpc
@L650D  lda     $95
        eor     $93
        and     #$07
        sta     $a1
        cmp     #$06
        bcs     @L651E
        adc     #$ec
        jsr     PrintTokSpc
@L651E  lda     $97
        and     #$03
        clc
        adc     $a1
        and     #$07
        adc     #$f2       ;Rodent, Frog, Lizard, ...
        jsr     PrintFlightToken
@L652C  lda     #$53       ;"S"
        jsr     PrintFlightToken
        lda     #$29       ;")"
        jsr     PrintFlightTokNL
        lda     #$c1       ;"Gross Productivity"
        jsr     PrintFlightTokCol
        ldx     $dc
        ldy     $dd
        jsr     L6C13
        jsr     PrintSpace
        lda     #$00
        sta     text_mod_flags
        lda     #$4d       ;"M"
        jsr     PrintFlightToken
        lda     #$e2       ;"Cr"
        jsr     PrintFlightTokNL
        lda     #$fa       ;"Average Radius"
        jsr     PrintFlightTokCol
        lda     $97
        ldx     $95
        and     #$0f
        clc
        adc     #$0b
        tay
        jsr     Print4XloYhi
        jsr     PrintSpace
        lda     #'k'
        jsr     PrintChar
        lda     #'m'
        jsr     PrintChar
        jsr     IncTextVpos1
        jmp     L626B

        !byte   $60

; BBC .TT24 "Calculate system Data"
L6579   lda     $93
        and     #$07
        sta     $d7
        lda     $94
        lsr
        lsr
        lsr
        and     #$07
        sta     $d8
        lsr
        bne     @L6591
        lda     $d7
        ora     #$02
        sta     $d7
@L6591  lda     $d7
        eor     #$07
        clc
        sta     $d9
        lda     $95
        and     #$03
        adc     $d9
        sta     $d9
        lda     $d8
        lsr
        adc     $d9
        sta     $d9
        asl
        asl
        adc     $d7
        adc     $d8
        adc     #$01
        sta     $da
        lda     $d7
        eor     #$07
        adc     #$03
        sta     $31
        lda     $d8
        adc     #$04
        sta     $ad
        jsr     L5F45
        lda     $da
        sta     $ad
        jsr     L5F45
        asl     $31
        rol
        asl     $31
        rol
        asl     $31
        rol
        sta     $dd
        lda     $31
        sta     $dc
        rts

; BBC .TT22 "Long range galactic chart"
GalacticChartScreen
        lda     #$40
        jsr     PrintFlightHud
        lda     #$07
        sta     text_hposn
        jsr     L6A93
        lda     #$c7       ;"Galactic Chart #"
        jsr     PrintFlightToken
        lda     #$12
        jsr     IncTextDrawLine
        lda     #$74
        sta     $6f
        lda     #$1f
        sta     $6e
        lda     #$e4
        sta     $70
        jsr     DrawHorizLine
        lda     #$1e
        jsr     L63D6
        lda     #$e2
        jsr     L63D6
        jsr     L66C0
        ldx     #$00
@L660D  stx     $b0
        lda     $95
        jsr     L63D0
        tax
        lda     #$ff
        sta     $b4
        lda     $93
        jsr     L63C3
        clc
        adc     #$13
        jsr     DrawStar
        jsr     L6418
        ldx     $b0
        inx
        bne     @L660D
        lda     $e0
        jsr     L63D0
        sta     $a1
        lda     $e1
        jsr     L63C3
        sta     $a2
        lda     #$04
        sta     $a3
        lda     #$08
        sta     $35
L6642   lda     #$13
        ldx     displayed_screen
        bpl     @L664A
        lda     #$00
@L664A  sta     $a6
        lda     $a1
        sec
        sbc     $a3
        bit     displayed_screen
        bmi     @L665B
        cmp     #$22
        bcs     @L665B
        lda     #$22
@L665B  sta     $6e
        lda     $a1
        clc
        adc     #$02
        adc     $a3
        bit     displayed_screen
        bmi     @L666E
        cmp     #$e0
        bcc     @L666E
        lda     #$e0
@L666E  sta     $70
        lda     $a2
        clc
        adc     $a6
        sta     $6f
        jsr     DrawHorizLine
        lda     $a2
        sec
        sbc     $a3
        bcs     @L6683
        lda     #$00
@L6683  clc
        adc     $a6
        sta     $6f
        lda     $a2
        clc
        adc     $a3
        adc     $a6
        cmp     #$73
        bcc     @L6699
        ldx     displayed_screen
        bmi     @L6699
        lda     #$73
@L6699  sta     $71
        lda     $a1
        sta     $6e
        jmp     DrawVerticalLine

L66A2   lda     #$69
        sta     $a1
        lda     #$4b
        sta     $a2
        lda     #$10
        sta     $a3
        lda     #$08
        sta     $35
        jsr     L6642
        lda     player_fuel
        jsr     L63C4
        sta     $7a
        jmp     L66EF

L66C0   lda     displayed_screen
        bmi     L66A2
        lda     player_fuel
        lsr
        jsr     L63C3
        sta     $7a
        lda     $0290
        jsr     L63D0
        sta     $a1
        lda     $0291
        jsr     L63C3
        sta     $a2
        lda     #$07
        sta     $a3
        lda     #$08
        sta     $35
        jsr     L6642
        lda     $a2
        clc
        adc     #$13
        sta     $a2
L66EF   lda     $a1
        sta     $38
        lda     $a2
        sta     $46
        ldx     #$00
        stx     $47
        stx     $39
        inx
        stx     $91
        ldx     #$02
        stx     $bf
        jmp     L77BA

DockBuyCargo
        lda     #$02
        jsr     L6411
        jsr     L6CB7
        lda     #$80
        sta     text_mod_flags
        lda     #$00
        sta     $02f0
@L6718  jsr     L6C25
        lda     $02ee
        bne     @L672F
        jmp     @L6795

@L6723  ldy     #$b0
@L6725  jsr     PrintSpace
        tya
        jsr     PrintTokQu
        jsr     L6FF0
@L672F  jsr     ClearLines
        lda     #$cc       ;"Quantity Of"
        jsr     PrintFlightToken
        lda     $02f0
        clc
        adc     #$d0       ;Food, Textiles, Radioactives, ...
        jsr     PrintFlightToken
        lda     #$2f       ;"/"
        jsr     PrintFlightToken
        jsr     L6C94
        lda     #$3f       ;"?"
        jsr     PrintFlightToken
        jsr     PrintFF
        ldx     #$00
        stx     $ae
        ldx     #$0c
        stx     $06
        jsr     L67B5
        bcs     @L6723
        sta     $31
        jsr     L63E8
        ldy     #$ce
        lda     $ae
        beq     @L676A
        bcs     @L6725
@L676A  lda     $02ed
        sta     $ad
        jsr     L6E78
        jsr     SubCredits
        ldy     #$c5
        bcc     @L6725
        ldy     $02f0
        lda     $ae
        pha
        clc
        adc     player_cargo,y
        sta     player_cargo,y
        lda     $02c4,y
        sec
        sbc     $ae
        sta     $02c4,y
        pla
        beq     @L6795
        jsr     L6FE8
@L6795  lda     $02f0
        clc
        adc     #$05
        jsr     L640B
        lda     #$00
        jsr     L6408
        inc     $02f0
        lda     $02f0
        cmp     #$11
        bcs     L67B0
        jmp     @L6718

L67B0   lda     #$30
        jmp     FromGameInit

L67B5   ldx     #$00
        stx     $ae
        ldx     #$0c
        stx     $06
@L67BD  jsr     GetInput1
        ldx     $ae
        bne     @L67CC
        cmp     #$59
        beq     @L67FD
        cmp     #$4e
        beq     @L6808
@L67CC  sta     $ad
        sec
        sbc     #$30
        bcc     @L67FA
        cmp     #$0a
        bcs     L67B0
        sta     $af
        lda     $ae
        cmp     #$1a
        bcs     @L67FA
        asl
        sta     $d0
        asl
        asl
        adc     $d0
        adc     $af
        sta     $ae
        cmp     $02ee
        beq     @L67F1
        bcs     @L67FA
@L67F1  lda     $ad
        jsr     PrintChar
        dec     $06
        bne     @L67BD
@L67FA  lda     $ae
        rts

@L67FD  jsr     PrintChar
        lda     $02ee
        sta     $ae
        jmp     @L67FA

@L6808  jsr     PrintChar
        lda     #$00
        sta     $ae
        jmp     @L67FA

L6812   jsr     PrintFF
        lda     #$b0
        jsr     PrintTokQu
        jsr     L6FF0
        ldy     $02f0
        jmp     L683F

DockSellCargo
        lda     #$04
        jsr     L6411
        lda     #$0a
        jsr     L6408
        lda     #$cd       ;"Sell"
        jsr     PrintFlightToken
        lda     #$ce       ;"Cargo"
        jsr     PrintFlightTokLine
        jsr     PrintFF
L683A   ldy     #$00
L683C   sty     $02f0
L683F   ldx     player_cargo,y
        beq     @L68AC
        tya
        asl
        asl
        tay
        lda     MarketData+1,y
        sta     $a2
        txa
        pha
        jsr     L6462
        clc
        lda     $02f0
        adc     #$d0       ;Food, Textiles, Radioactives, ...
        jsr     PrintFlightToken
        lda     #$0e
        jsr     L6408
        pla
        tax
        sta     $02ee
        clc
        jsr     PrintNumInX
        jsr     L6C94
        lda     displayed_screen
        cmp     #$04
        bne     @L68AC
        lda     #$cd       ;"Sell"
        jsr     PrintFlightToken
        lda     #$ce       ;"(Y/N)?"
        jsr     PrintDockedStr
        jsr     L67B5
        beq     @L68AC
        bcs     L6812
        lda     $02f0
        ldx     #$ff
        stx     text_mod_flags
        jsr     L6C25
        ldy     $02f0
        lda     player_cargo,y
        sec
        sbc     $ae
        sta     player_cargo,y
        lda     $ae
        sta     $31
        lda     $02ed
        sta     $ad
        jsr     L6E78
        jsr     AddCredits
        lda     #$00
        sta     text_mod_flags
@L68AC  ldy     $02f0
        iny
        cpy     #$11
        bcc     L683C
        lda     displayed_screen
        cmp     #$04
        bne     @L68C0
        jsr     L6FF0
        jmp     L67B0

@L68C0  jsr     L6462
        lda     $02bf
        ora     kill_score_rem-1
        bne     @L68CC
@L68CB  rts

@L68CC  clc
        lda     #$00
        ldx     $02bf
        ldy     kill_score_rem-1
        jsr     L5468
        jsr     GetRandom
        and     #$03
        clc
        adc     #$6f
        jsr     PrintDockedStr
        lda     #$c6
        jsr     PrintDockedStr
        lda     kill_score_rem-1
        bne     @L68F3
        ldx     $02bf
        dex
        beq     @L68CB
@L68F3  lda     #$73
        jmp     PrintChar

CargoListScreen
        lda     #$08
        jsr     L6411
        lda     #$0b
        jsr     L6408
        lda     #$a4       ;"Inventory"
        jsr     PrintFlightTokNL
        jsr     T4EA9
        jsr     PrintFuelCash
        lda     cargo_capacity ;do we have the cargo bay expander?
        cmp     #26
        bcc     @L6919
        lda     #$6b       ;"Large Cargo Bay"
        jsr     PrintFlightToken
@L6919  jmp     L683A

YN_unref
        jsr     PrintFlightToken
        lda     #$ce       ;"(Y/N)?"
        jsr     PrintDockedStr
        jsr     GetInput1
        ora     #$20
        cmp     #'y'
        beq     @L6932
        lda     #'n'
        jmp     PrintChar

@L6932  jsr     PrintChar
        sec
        rts

L6937   txa
        pha
        dey
        tya
        eor     #$ff
        pha
        jsr     Delay
        jsr     L6960
        pla
        sta     $a4
        lda     $e1
        jsr     L697D
        lda     $a5
        sta     $e1
        sta     $a2
        pla
        sta     $a4
        lda     $e0
        jsr     L697D
        lda     $a5
        sta     $e0
        sta     $a1
L6960   lda     #$08
        sta     $35
        lda     displayed_screen
        bmi     L698E
        lda     $e0
        jsr     L63D0
        sta     $a1
        lda     $e1
        jsr     L63C3
        sta     $a2
        lda     #$04
        sta     $a3
        jmp     L6642

L697D   sta     $a5
        clc
        adc     $a4
        ldx     $a4
        bmi     @L6989
        bcc     @L698B
        rts

@L6989  bcc     L698D
@L698B  sta     $a5
L698D   rts

L698E   lda     $e0
        sec
        sbc     $0290
        cmp     #$1d
        bcc     @L699C
        cmp     #$e3
        bcc     L698D
@L699C  asl
        asl
        clc
        adc     #$8c
        jsr     L63C4
        sta     $a1
        lda     $e1
        sec
        sbc     $0291
        cmp     #$23
        bcc     @L69B4
        cmp     #$e6
        bcc     L698D
@L69B4  asl
        clc
        adc     #$63
        jsr     L63C4
        sta     $a2
        lda     #$08
        sta     $a3
        lda     #$08
        sta     $35
        jmp     L6642

LocalChartScreen
        lda     #$80
        jsr     PrintFlightHud
        lda     #$07
        sta     text_hposn
        lda     #$be       ;"Short Range Chart"
        jsr     PrintFlightTokLine
        jsr     L66C0
        jsr     L6960
        jsr     L6A93
        lda     #$00
        sta     $c1
        ldx     #$18
@L69E5  sta     polyobj_xpos_lo,x
        dex
        bpl     @L69E5
@L69EA  lda     $95
        sec
        sbc     $0290
        bcs     @L69F6
        eor     #$ff
        adc     #$01
@L69F6  cmp     #$1d
        bcs     @L6A5D
        lda     $93
        sec
        sbc     $0291
        bcs     @L6A06
        eor     #$ff
        adc     #$01
@L6A06  cmp     #$28
        bcs     @L6A5D
        lda     $95
        sec
        sbc     $0290
        asl
        asl
        adc     #$8c
        jsr     L63C4
        sta     $74
        lsr
        lsr
        lsr
        clc
        adc     #$01
        sta     text_hposn
        lda     $93
        sec
        sbc     $0291
        asl
        adc     #$63
        jsr     L63C4
        sta     $46
        lsr
        lsr
        lsr
        tay
        ldx     polyobj_xpos_lo,y
        beq     @L6A42
        iny
        ldx     polyobj_xpos_lo,y
        beq     @L6A42
        dey
        dey
        ldx     polyobj_xpos_lo,y
        bne     @L6A6B
@L6A42  sty     text_vposn
        cpy     #$03
        bcc     @L6A88
        cpy     #$11
        bcs     @L6A88
        tya
        pha
        lda     $95
        jsr     L6AF1
        pla
        tay
        lda     $df
        bne     @L6A88
        lda     $de
        cmp     #$46
@L6A5D  bcs     @L6A88
        lda     #$ff
        sta     polyobj_xpos_lo,y
        lda     #$80
        sta     text_mod_flags
        jsr     PrintSelPlanet
@L6A6B  lda     #$00
        sta     $39
        sta     $47
        sta     $7b
        lda     $74
        sta     $38
        lda     $97
        and     #$01
        adc     #$02
        sta     $7a
        jsr     L7428
        jsr     L767B
        jsr     L7428
@L6A88  jsr     L6418
        inc     $c1
        beq     @L6A92
        jmp     @L69EA

@L6A92  rts

L6A93   ldx     #$05
@L6A95  lda     $0292,x
        sta     $92,x
        dex
        bpl     @L6A95
        rts

L6A9E   jsr     L6A93
        ldy     #$7f
        sty     $d0
        lda     #$00
        sta     $ac
@L6AA9  lda     $95
        sec
        sbc     $e0
        bcs     @L6AB4
        eor     #$ff
        adc     #$01
@L6AB4  lsr
        sta     $af
        lda     $93
        sec
        sbc     $e1
        bcs     @L6AC2
        eor     #$ff
        adc     #$01
@L6AC2  lsr
        clc
        adc     $af
        cmp     $d0
        bcs     @L6AD9
        sta     $d0
        ldx     #$05
@L6ACE  lda     $92,x
        sta     $a1,x
        dex
        bpl     @L6ACE
        lda     $ac
        sta     $b4
@L6AD9  jsr     L6418
        inc     $ac
        bne     @L6AA9
        ldx     #$05
@L6AE2  lda     $a1,x
        sta     $92,x
        dex
        bpl     @L6AE2
        lda     $93
        sta     $e1
        lda     $95
        sta     $e0
L6AF1   sec
        sbc     $0290
        bcs     @L6AFB
        eor     #$ff
        adc     #$01
@L6AFB  jsr     L5F32
        sta     $7b
        lda     $31
        sta     $7a
        lda     $93
        sec
        sbc     $0291
        bcs     @L6B10
        eor     #$ff
        adc     #$01
@L6B10  lsr
        jsr     L5F32
        pha
        lda     $31
        clc
        adc     $7a
        sta     $ad
        pla
        adc     $7b
        bcc     @L6B23
        lda     #$ff
@L6B23  sta     $ae
        jsr     TwoByteSqrt
        lda     $ad
        asl
        ldx     #$00
        stx     $df
        rol     $df
        asl
        rol     $df
        sta     $de
        jmp     L6579

L6B39   jsr     ClearLines
        lda     #$0f
        jsr     L6408
        lda     #$cd
        jmp     PrintDockedStr

L6B46   lda     docked_flag
        bne     L6B39
        lda     $69
        beq     @L6B4F
        rts

@L6B4F  lda     input_raw_key
        cmp     #$47
        beq     @L6BAF
        lda     displayed_screen
        beq     @L6BA9
        and     #$c0
        bne     @L6B5E
        rts

@L6B5E  jsr     L705B
@L6B61  lda     $de
        ora     $df
        bne     @L6B68
        rts

@L6B68  ldx     #$05
@L6B6A  lda     $92,x
        sta     $02fb,x
        dex
        bpl     @L6B6A
        lda     #$07
        sta     text_hposn
        lda     #$16
        ldy     display_mode_flag
        bmi     @L6B7E
        lda     #$10
@L6B7E  sta     text_vposn
        lda     #$00
        sta     text_mod_flags
        lda     #$bd       ;"Hyperspace"
        jsr     PrintFlightToken
        lda     $df
        bne     @L6B94
        lda     player_fuel
        cmp     $de
        bcs     @L6B97
@L6B94  jmp     PrintRangeQu

@L6B97  lda     #$2d       ;"-"
        jsr     PrintFlightToken
        jsr     PrintSelPlanet
        lda     #$0f
@L6BA1  sta     $69
        sta     $68
        tax
        jmp     L6C03

@L6BA9  jsr     L6A9E
        jmp     @L6B61

@L6BAF  ldx     have_galactic_hyper
        beq     @L6BD8
        inx
        stx     have_galactic_hyper
        stx     player_fug_inno
        lda     #$02
        jsr     @L6BA1
        ldx     #$05
        inc     ship_state2
        lda     ship_state2
        and     #$f7
        sta     ship_state2
@L6BCD  lda     $0292,x
        asl
        rol     $0292,x
        dex
        bpl     @L6BCD
        !byte   $a9
@L6BD8  rts

        sta     $e0
        sta     $e1
        jsr     LaunchOrLook
        jsr     L6A9E
        ldx     #$05
@L6BE5  lda     $92,x
        sta     $02fb,x
        dex
        bpl     @L6BE5
        ldx     #$00
        stx     $de
        stx     $df
        lda     #$74       ;"Galactic Hyperspace"
        jsr     PrintMessageBriefly
L6BF8   lda     $e0
        sta     $0290
        lda     $e1
        sta     $0291
        rts

L6C03   lda     #$01
        jsr     L6408
        jsr     L640B
        ldy     #$00
        clc
        lda     #$03
        jmp     L5468

L6C13   clc
Print4XloYhi
        lda     #$05
        jmp     L5468

PrintRangeQu
        lda     #$ca       ;"Range"
PrintTokQu
        jsr     PrintFlightToken
        lda     #$3f       ;"?"
        jmp     PrintFlightToken

L6C23   pla
        rts

L6C25   pha
        sta     $a5
        asl
        asl
        sta     $a1
        lda     witch_space_flag
        bne     L6C23
        lda     #$01
        sta     text_hposn
        pla
        adc     #$d0       ;Food, Textiles, Radioactives, ...
        jsr     PrintFlightToken
        lda     #$0e
        sta     text_hposn
        ldx     $a1
        lda     MarketData+1,x
        sta     $a2
        lda     kill_score-1
        and     MarketData+3,x
        clc
        adc     MarketData,x
        sta     $02ed
        jsr     L6C94
        jsr     L6CF1
        lda     $a2
        bmi     @L6C65
        lda     $02ed
        adc     $a4
        jmp     @L6C6B

@L6C65  lda     $02ed
        sec
        sbc     $a4
@L6C6B  sta     $02ed
        sta     $31
        lda     #$00
        jsr     L6E7B
        sec
        jsr     Print4XloYhi
        ldy     $a5
        lda     #$05
        ldx     $02c4,y
        stx     $02ee
        clc
        beq     @L6C8C
        jsr     L5466
        jmp     L6C94

@L6C8C  lda     #$19
        sta     text_hposn
        lda     #$2d
        bne     L6CA3

L6C94   lda     $a2
        and     #$60
        beq     L6CA6
        cmp     #$20
        beq     L6CAD
        jsr     L6CB2
PrintSpace
        lda     #$20       ;" "
L6CA3   jmp     PrintFlightToken

L6CA6   lda     #$74
        jsr     PrintChar
        bcc     PrintSpace
L6CAD   lda     #$6b
        jsr     PrintChar
L6CB2   lda     #$67
        jmp     PrintChar

L6CB7   lda     #$11
        sta     text_hposn
        lda     #$ff
        bne     L6CA3

LocalMarketScreen
        lda     #$10
        jsr     L6411
        lda     #$05
        sta     text_hposn
        lda     #$a7       ;"[cur-planet] Market Prices"
        jsr     PrintFlightTokLine
        lda     #$03
        sta     text_vposn
        jsr     L6CB7
        lda     #$06
        sta     text_vposn
        lda     #$00
        sta     $02f0
@L6CDD  ldx     #$80
        stx     text_mod_flags
        jsr     L6C25
        inc     text_vposn
        inc     $02f0
        lda     $02f0
        cmp     #$11
        bcc     @L6CDD
        rts

L6CF1   lda     $a2
        and     #$1f
        ldy     $02ef
        sta     $a3
        clc
        lda     #$00
        sta     $02d4
@L6D00  dey
        bmi     @L6D08
        adc     $a3
        jmp     @L6D00

@L6D08  sta     $a4
        rts

        !byte   $20
        !byte   $9e
        !byte   $6a

L6D0E   jsr     L6BF8
        ldx     #$05
@L6D13  lda     $02fb,x
        sta     $02f5,x
        dex
        bpl     @L6D13
        inx
        stx     PLAYER_STATE+53
        lda     $d7
        sta     $02ef
        lda     $d9
        sta     $02f2
        lda     $d8
        sta     $02f1
        jsr     GetRandom
        sta     kill_score-1
        ldx     #$00
        stx     $c0
@L6D39  lda     MarketData+1,x
        sta     $a2
        jsr     L6CF1
        lda     MarketData+3,x
        and     kill_score-1
        clc
        adc     MarketData+2,x
        ldy     $a2
        bmi     @L6D55
        sec
        sbc     $a4
        jmp     @L6D58

@L6D55  clc
        adc     $a4
@L6D58  bpl     @L6D5C
        lda     #$00
@L6D5C  ldy     $c0
        and     #$3f
        sta     $02c4,y
        iny
        tya
        sta     $c0
        asl
        asl
        tax
        cmp     #$3f
        bcc     @L6D39
        rts

L6D6F   jsr     L7B5A
        lda     #$ff
        sta     polyobj_attack
        lda     #$1d
        jsr     L7545
        lda     #$1e
        jmp     L7545

L6D80   lsr     ship_state1
        sec
        rol     ship_state1
L6D87   lda     #$03
        jsr     PrintFlightHud
        jsr     L5D29
        jsr     RES2
        sty     witch_space_flag
@L6D95  jsr     L6D6F
        lda     #$02
        cmp     PLAYER_STATE+38
        bcs     @L6D95
        sta     $e2
        ldx     #$00
        jsr     SetViewDirection
        lda     $0291
        eor     #$1f
        sta     $0291
        rts

L6DAF   rts

L6DB0   lda     player_fuel
        sec
        sbc     $de
        bcs     @L6DBA
        lda     #$00
@L6DBA  sta     player_fuel
        lda     displayed_screen
        bne     @L6DC7
        jsr     PrintFlightHud
        jsr     L5D29
@L6DC7  jsr     CheckForInput
        cmp     #$09
        bne     @L6DD3
        lda     ptb_pausecmd_x
        bmi     L6D80
@L6DD3  jsr     GetRandom
        cmp     #$fd
        bcs     L6D87
        jsr     L6D0E
        jsr     RES2
        jsr     L7379
        lda     displayed_screen
        and     #$3f
        bne     L6DAF
        jsr     L94BB
        lda     displayed_screen
        bne     L6E28
        inc     displayed_screen
LaunchOrLook
        ldx     docked_flag ;are we docked?
        beq     @SetFrontView ;no, branch
        jsr     DrawOctagonRings ;launch from dock
        jsr     RES2
        jsr     L6A9E
        inc     polyobj_zpos_hi
        jsr     L7366
        lda     #$80
        sta     polyobj_zpos_hi
        inc     polyobj_zpos_mi
        jsr     L74FE
        lda     #$0c
        sta     player_speed
        jsr     CountIllegalCargo
        ora     player_fug_inno
        sta     player_fug_inno
        lda     #$ff
        sta     displayed_screen
        jsr     L5D58
@SetFrontView
        ldx     #$00       ;clear docked flag
        stx     docked_flag
        jmp     SetViewDirection ;set view to forward

L6E28   bmi     @L6E2D
        jmp     GalacticChartScreen

@L6E2D  jmp     LocalChartScreen

; 
; Subtract credits from player's account.
; 
; On entry:
;   X-reg: low part
;   Y-reg: high part
SubCredits
        stx     $06
        lda     player_credits+3
        sec
        sbc     $06
        sta     player_credits+3
        sty     $06
        lda     player_credits+2
        sbc     $06
        sta     player_credits+2
        lda     player_credits+1
        sbc     #$00
        sta     player_credits+1
        lda     player_credits
        sbc     #$00
        sta     player_credits
        bcs     Return1    ;always?
; 
; Add credits to player's account.
; 
; On entry:
;   X-reg: low part
;   Y-reg: high part
AddCredits
        txa
        clc
        adc     player_credits+3
        sta     player_credits+3
        tya
        adc     player_credits+2
        sta     player_credits+2
        lda     player_credits+1
        adc     #$00
        sta     player_credits+1
        lda     player_credits
        adc     #$00
        sta     player_credits
        clc
Return1 rts

L6E78   jsr     L5F45
L6E7B   asl     $31
        rol
        asl     $31
        rol
        tay
        ldx     $31
        rts

L6E85   jmp     L7F2D

DockEquipShip
        lda     #$20
        jsr     L6411
        lda     #$0c
        sta     text_hposn
        lda     #$cf
        jsr     PrintTokSpc
        lda     #$b9       ;"Ship"
        jsr     PrintFlightTokLine
        lda     #$80
        sta     text_mod_flags
        jsr     IncTextVposn
        lda     $02f2
        clc
        adc     #$03
        cmp     #$0c
        bcc     @L6EAE
        lda     #$0e
@L6EAE  sta     $ad
        sta     $02ee
        inc     $ad
        lda     #$46
        sec
        sbc     player_fuel
        asl
        sta     equip_prices
        ldx     #$01
@L6EC1  stx     $b5
        jsr     PrintFF
        ldx     $b5
        clc
        jsr     PrintNumInX
        jsr     PrintSpace
        lda     $b5
        clc
        adc     #$68       ;Beam Laser, Fuel, Missile, ...
        jsr     PrintFlightToken
        lda     $b5
        jsr     L7008
        sec
        lda     #$19
        sta     text_hposn
        lda     #$06
        jsr     L5468
        ldx     $b5
        inx
        cpx     $ad
        bcc     @L6EC1
        jsr     ClearLines
        lda     #$7f
        jsr     PrintTokQu
        jsr     L67B5
        beq     L6E85
        bcs     L6E85
        sbc     #$00
        pha
        lda     #$02
        sta     text_hposn
        inc     text_vposn
        pla
        pha
        jsr     L6FF8
        pla
        bne     @NotFuel
        ldx     #$46       ;A-reg=0 -> fuel
        stx     player_fuel
@NotFuel
        cmp     #$01       ;missile?
        bne     @NotMissile
        ldx     missile_armed_flag
        inx
        ldy     #$7c
        cpx     #$05
        bcs     L6F6A
        stx     missile_armed_flag
        jsr     L7B29
        lda     #$01
@NotMissile
        ldy     #$6b
        cmp     #$02       ;large cargo bay?
        bne     @NotLCB
        ldx     #$25
        cpx     cargo_capacity
        beq     L6F6A
        stx     cargo_capacity
@NotLCB cmp     #$03       ;ECM system?
        bne     @NotEcm
        iny
        ldx     have_ecm
        bne     L6F6A
        dec     have_ecm
@NotEcm cmp     #$04       ;extra pulse lasers?
        bne     @NotPulse
        jsr     PrintLaserInfo
        lda     #$0f
        jsr     L7067
        lda     #$04
@NotPulse
        cmp     #$05       ;extra beam lasers?
        bne     @NotBeam
        jsr     PrintLaserInfo
        lda     #$8f
        jsr     L7067
@NotBeam
        ldy     #$6f
        cmp     #$06       ;fuel scoops?
        bne     NotScoop
        ldx     have_fuel_scoop
        beq     L6F82
L6F6A   sty     $7a
        jsr     L700B
        jsr     AddCredits
        lda     $7a
        jsr     PrintTokSpc
        lda     #$1f       ;"Present"
        jsr     PrintFlightToken
L6F7C   jsr     L6FF0
        jmp     L7F2D

L6F82   dec     have_fuel_scoop
NotScoop
        iny
        cmp     #$07       ;escape pod?
        bne     @NotEscape
        ldx     have_escape_pod
        bne     L6F6A
        dec     have_escape_pod
@NotEscape
        iny
        cmp     #$08       ;energy bomb?
        bne     @NotBomb
        ldx     have_energy_bomb
        bne     L6F6A
        ldx     #$7f
        stx     have_energy_bomb
@NotBomb
        iny
        cmp     #$09       ;energy unit?
        bne     @NotEnergy
        ldx     have_energy_unit
        bne     L6F6A
        inc     have_energy_unit
@NotEnergy
        iny
        cmp     #$0a       ;docking computer?
        bne     @NotDockComp
        ldx     have_docking_comp
        bne     L6F6A
        dec     have_docking_comp
@NotDockComp
        iny
        cmp     #$0b       ;galactic hyperspace?
        bne     @NotGalHyper
        ldx     have_galactic_hyper
        bne     L6F6A
        dec     have_galactic_hyper
@NotGalHyper
        iny
        cmp     #$0c       ;military laser?
        bne     @L6FD5
        jsr     PrintLaserInfo
        lda     #$97
        jsr     L7067
@L6FD5  iny
        cmp     #$0d       ;mining laser?
        bne     @L6FE2
        jsr     PrintLaserInfo
        lda     #$32
        jsr     L7067
@L6FE2  jsr     L6FE8
        jmp     DockEquipShip

L6FE8   jsr     PrintSpace
        lda     #$77       ;"Cash: $$$$$$.0 Cr"
        jsr     PrintTokSpc
L6FF0   jsr     Noise1
        ldy     #$19
        jmp     LongDelay

L6FF8   jsr     L700B
        jsr     SubCredits
        bcs     L7014
        lda     #$c5       ;"Cash"
        jsr     PrintTokQu
        jmp     L6F7C

L7008   sec
        sbc     #$01
L700B   asl
        tay
        ldx     equip_prices,y
        lda     equip_prices+1,y
        tay
L7014   rts

PrintLaserInfo
        lda     $02f2
        cmp     #$08
        bcc     @L7021
        lda     #$20
        jsr     PrintFlightHud
@L7021  lda     #$10
        tay
        sta     text_vposn
@L7026  lda     #$0c
        sta     text_hposn
        tya
        clc
        adc     #$20
        jsr     PrintTokSpc
        lda     text_vposn
        clc
        adc     #$50       ;P, Q, R, ...
        jsr     PrintFlightToken
        inc     text_vposn
        ldy     text_vposn
        cpy     #$14
        bcc     @L7026
        jsr     ClearLines
@L7044  lda     #$af       ;"View"
        jsr     PrintTokQu
        jsr     GetInput1
        sec
        sbc     #$30
        cmp     #$04
        bcc     @L7059
        jsr     ClearLines
        jmp     @L7044

@L7059  tax
        rts

L705B   jsr     L6960
        jsr     L6A9E
        jsr     L6960
        jmp     ClearLines

L7067   sta     $06
        lda     $029f,x
        beq     @L708D
        ldy     #$04
        cmp     #$0f
        beq     @L7082
        ldy     #$05
        cmp     #$8f
        beq     @L7082
        ldy     #$0c
        cmp     #$97
        beq     @L7082
        ldy     #$0d
@L7082  stx     $b4
        tya
        jsr     L700B
        jsr     AddCredits
        ldx     $b4
@L708D  lda     $06
        sta     $029f,x
        rts

equip_prices
        !word   1          ;fuel (updated for quantity currently in ship)
        !word   300        ;Missile (30.0 Cr)
        !word   4000       ;Large Cargo Bay (400.0 Cr)
        !word   6000       ;E.C.M. System
        !word   4000       ;Pulse Laser
        !word   10000      ;Beam Laser
        !word   5250       ;Fuel Scoop
        !word   10000      ;Escape Pod
        !word   9000       ;Energy Bomb
        !word   15000      ;Energy Unit
        !word   10000      ;Docking Computers
        !word   50000      ;Galactic Hyperdrive
        !word   60000      ;Military Laser
        !word   8000       ;Mining Laser

PrintSelPlanet
        ldx     #$05
@L70B1  lda     $92,x
        sta     $a1,x
        dex
        bpl     @L70B1
        ldy     #$03
        bit     $92
        bvs     @L70BF
        dey
@L70BF  sty     $d0
@L70C1  lda     $97
        and     #$1f
        beq     @L70CC
        ora     #$80
        jsr     PrintFlightToken
@L70CC  jsr     L641E
        dec     $d0
        bpl     @L70C1
        ldx     #$05
@L70D5  lda     $a1,x
        sta     $92,x
        dex
        bpl     @L70D5
        rts

PrintCmdrName
        ldy     #$00
@L70DF  lda     $0287,y
        cmp     #$0d
        beq     @L70EC
        jsr     PrintChar
        iny
        bne     @L70DF
@L70EC  rts

PrintCurPlanet
        bit     witch_space_flag
        bmi     @L7107
        jsr     @L70F8
        jsr     PrintSelPlanet
@L70F8  ldx     #$05
@L70FA  lda     $92,x
        ldy     $02f5,x
        sta     $02f5,x
        sty     $92,x
        dex
        bpl     @L70FA
@L7107  rts

PrintGalNum
        clc
        ldx     ship_state2
        inx
        jmp     PrintNumInX

PrintFuelCash
        lda     #$69       ;"Fuel"
        jsr     PrintFlightTokCol ;":"
        ldx     player_fuel
        sec
        jsr     PrintNumInX
        lda     #$c3       ;" Light Years"
        jsr     PrintTokFF
        lda     #$77       ;"Cash:" + account balance
        bne     PrintFlightToken

PrintCash
        ldx     #$03
@L7127  lda     player_credits,x
        sta     $7a,x
        dex
        bpl     @L7127
        lda     #$09
        sta     $ac
        sec
        jsr     PrintNumber
        lda     #$e2       ;" Cr"
PrintTokFF
        jsr     PrintFlightToken
        jmp     PrintFF

; 
; Prints a flight token, followed by a ':'.
; 
PrintFlightTokCol
        jsr     PrintFlightToken
PrintColon
        lda     #':'
; 
; Prints a flight string token.  This can be a single letter, a variable, a
; string expansion, or a meta command.
; 
; See also https://xania.org/201406/elites-crazy-string-format
; 
; Values:
;   $00-0d: special values, e.g. current cash on hand
;   $0e-1f: canned messages 128-145
;   $20-5f: ASCII
;   $60-7f: canned messages 96-127
;   $80-9f: flight digram
;   $a0-ff: canned messages 0-95
; 
; On entry:
;   A-reg: token (already "decrypted")
; 
PrintFlightToken
        tax
        beq     PrintCash  ;token=0: print account balance
        bmi     @PrintCanOrDigram ;token >= 128, branch
        dex
        beq     PrintGalNum ;token=1: print galaxy number
        dex
        beq     PrintCurPlanet ;token=2: print current planet name
        dex
        bne     @Not0123
        jmp     PrintSelPlanet ;token=3: print selected planet name

@Not0123
        dex
        beq     PrintCmdrName ;token=4: commander name
        dex
        beq     PrintFuelCash ;token=5: fuel, followed by cash
        dex
        bne     @Not456
        lda     #$80       ;token=6: set text flags to $80
        sta     text_mod_flags
        rts

@Not456 dex
        dex
        bne     @Not8
        stx     text_mod_flags ;token=8: set text flags to $00
        rts

@Not8   dex
        beq     @PrintMidColon ;token=9: hposn to col 21, output ':'
        cmp     #$60       ;original token >= $60?
        bcs     PrintCannedMsg ;yes, print canned message
        cmp     #$0e       ;< $0e (7/9/a/b/c/d)?
        bcc     @HandleLo  ;yes, print as text (bell, LF, CR, etc)
        cmp     #$20       ;< $20 ($0e-$1f)?
        bcc     @Handle0e_1f ;yes, print as canned
@HandleLo
        ldx     text_mod_flags ;get the flags
        beq     @DoPrint2  ;none set, print it
        bmi     @L7190     ;high bit set
        bit     text_mod_flags ;check bit 6 (convert-to-lower)
        bvs     @PrintAndClear6 ;bit 7 clear, bit 6 set; print upper then clear bit 6
@L7183  cmp     #'A'       ;< 'A'?
        bcc     @DoPrint1
        cmp     #'['       ;> 'Z'?
        bcs     @DoPrint1
        adc     #$20       ;convert to lower case
@DoPrint1
        jmp     PrintChar

@L7190  bit     text_mod_flags
        bvs     @Bit76Set
        cmp     #'A'       ;< 'A'?
        bcc     @DoPrint2  ;just print it
        pha
        txa                ;get text_mod_flags
        ora     #$40       ;set bit 6, so next char is lower case
        sta     text_mod_flags
        pla
        bne     @DoPrint1  ;(always)
@Handle0e_1f
        adc     #$72       ;add $72 (now $80-91)
        bne     PrintCannedMsg ;(always)
@PrintMidColon
        lda     #21
        sta     text_hposn
        jmp     PrintColon

@Bit76Set
        cpx     #$ff       ;both flags set; is it just $ff?
        beq     Done       ;yes, print nothing
        cmp     #'A'       ;>= 'A'?
        bcs     @L7183     ;conv lower
@PrintAndClear6
        pha                ;preserve A-reg
        txa                ;get text_mod_flags
        and     #$bf       ;clear bit 6 in the text flags
        sta     text_mod_flags
        pla
@DoPrint2
        jmp     PrintChar

@PrintCanOrDigram
        cmp     #$a0       ;outside digram range?
        bcs     @CannedStr ;yes, it's a canned string
        and     #$7f       ;no, pull two chars out of digram table
        asl                ; using token value -128 as index
        tay
        lda     flight_digram_tab,y ;first char
        jsr     PrintFlightToken ;print (recursively)
        lda     flight_digram_tab+1,y ;second char
        cmp     #'?'       ;one entry ends with '?'
        beq     Done       ;do nothing
        jmp     PrintFlightToken ;print (tail recursion)

        !zone   Z0067d6
.data_ptr =     $5e
@CannedStr
        sbc     #$a0       ;reduce to canned message index
; 
; Prints a string from the canned flight message table.  The table is filled
; with null-terminated strings, so we need to scan forward to find the one we
; want.
; 
; On entry:
;   A-reg: message index
; 
PrintCannedMsg
        tax                ;save A-reg
        lda     #<flight_text
        sta     .data_ptr
        lda     #>flight_text
        sta     .data_ptr+1
        ldy     #$00
        txa                ;restore A-reg
        beq     @PrintStrLoop ;special case entry 0
@ScanLoop
        lda     (.data_ptr),y ;get byte from compressed text
        beq     @StringEnd ;found zero terminator
        iny                ;advance ptr
        bne     @ScanLoop
        inc     .data_ptr+1
        bne     @ScanLoop  ;(always)
@StringEnd
        iny                ;advance string ptr
        bne     @NoInc
        inc     .data_ptr+1
@NoInc  dex                ;dec string index
        bne     @ScanLoop  ;haven't found the right one yet
@PrintStrLoop
        tya
        pha                ;save current data pointer
        lda     .data_ptr+1
        pha
        lda     (.data_ptr),y ;get token
        eor     #EOR_FLIGHT ;"decrypt" value
        jsr     PrintFlightToken ;process it
        pla                ;restore data ptr
        sta     .data_ptr+1
        pla
        tay
        iny                ;advance to next char
        bne     @NoInc1
        inc     .data_ptr+1
@NoInc1 lda     (.data_ptr),y ;get next token
        bne     @PrintStrLoop ;if not end of string, loop
Done    rts

        !byte   $a2
        !byte   $39
        !byte   $b5
        !byte   $00
        !byte   $b4
        !byte   $00
        !byte   $95
        !byte   $00
        !byte   $94
        !byte   $00
        !byte   $e8
        !byte   $d0
        !byte   $f5
        !byte   $60

L7222   lda     polyobj_vis
        ora     #$a0
        sta     polyobj_vis
        rts

DoExplosion
        lda     polyobj_vis
        and     #$40
        beq     @L7232
        jsr     @L728F
@L7232  lda     polyobj_zpos_lo
        sta     $d0
        lda     polyobj_zpos_mi
        cmp     #$20
        bcc     @L7240
        lda     #$fe
        bne     @L7248

@L7240  asl     $d0
        rol
        asl     $d0
        rol
        sec
        rol
@L7248  sta     $ad
        ldy     #$01
        lda     (tmp_ptr2),y
        sta     $0301
        adc     #$04
        bcs     L7222
        sta     (tmp_ptr2),y
        jsr     L60CE
        lda     $31
        cmp     #$1c
        bcc     @L7264
        lda     #$fe
        bne     @L726D

@L7264  asl     $ae
        rol
        asl     $ae
        rol
        asl     $ae
        rol
@L726D  dey
        sta     (tmp_ptr2),y
        lda     polyobj_vis
        and     #$bf
        sta     polyobj_vis
        and     #$08
        beq     Done
        ldy     #$02
        lda     (tmp_ptr2),y
        tay
@L727F  lda     $00f9,y
        sta     (tmp_ptr2),y
        dey
        cpy     #$06
        bne     @L727F
        lda     polyobj_vis
        ora     #$40
        sta     polyobj_vis
@L728F  ldy     #$00
        lda     (tmp_ptr2),y
        sta     $ad
        iny
        lda     (tmp_ptr2),y
        bpl     @L729C
        eor     #$ff
@L729C  lsr
        lsr
        lsr
        lsr
        ora     #$01
        sta     $ac
        iny
        lda     (tmp_ptr2),y
        sta     $bb
        lda     rng_state+1
        pha
        ldy     #$06
@L72AE  ldx     #$03
@L72B0  iny
        lda     (tmp_ptr2),y
        sta     $38,x
        dex
        bpl     @L72B0
        sty     $bd
        ldy     #$02
@L72BC  iny
        lda     (tmp_ptr2),y
        eor     $bd
        sta     $ffff,y
        cpy     #$06
        bne     @L72BC
        ldy     $ac
        sty     $be
@L72CC  clc
        lda     rng_state
        rol
        tax
        adc     rng_state+2
        sta     rng_state
        stx     rng_state+2
        lda     rng_state+1
        tax
        adc     rng_state+3
        sta     rng_state+1
        stx     rng_state+3
        and     #$0c
        ora     #$10
        sta     $35
        lda     $39
        sta     $ae
        lda     $38
        jsr     @L7331
        bne     @L731A
        cpx     #$87
        bcs     @L731A
        stx     $6f
        lda     $3b
        sta     $ae
        lda     $3a
        jsr     @L7331
        bne     @L7307
        lda     $6f
        jsr     DrawColorPixel
@L7307  dec     $be
        bpl     @L72CC
        ldy     $bd
        cpy     $bb
        bcc     @L72AE
        pla
        sta     rng_state+1
        lda     data_buffer+6
        sta     rng_state+3
        rts

@L731A  clc
        lda     rng_state
        rol
        tax
        adc     rng_state+2
        sta     rng_state
        stx     rng_state+2
        lda     rng_state+1
        tax
        adc     rng_state+3
        sta     rng_state+1
        stx     rng_state+3
        jmp     @L7307

@L7331  sta     $af
        clc
        lda     rng_state
        rol
        tax
        adc     rng_state+2
        sta     rng_state
        stx     rng_state+2
        lda     rng_state+1
        tax
        adc     rng_state+3
        sta     rng_state+1
        stx     rng_state+3
        rol
        bcs     @L7355
        jsr     FMLTU
        adc     $ae
        tax
        lda     $af
        adc     #$00
        rts

@L7355  jsr     FMLTU
        sta     $d0
        lda     $ae
        sbc     $d0
        tax
        lda     $af
        sbc     #$00
        rts

        !byte   $00
        !byte   $02

L7366   jsr     L7B29
        lda     #$7f
        sta     polyobj_roll
        sta     polyobj_pitch
        lda     $02f2
        and     #$02
        ora     #$80
        jmp     L7545

L7379   lda     $02bf
        beq     @L739C
        lda     #$00
        sta     player_cargo
        sta     player_cargo+6
        jsr     GetRandom
        and     #$0f
        adc     $02bf
        ora     #$04
        rol
        sta     $02bf
        rol     kill_score_rem-1
        bpl     @L739C
        ror     kill_score_rem-1
@L739C  lsr     player_fug_inno
        jsr     ZeroInfo
        lda     $93
        and     #$03
        adc     #$03
        sta     polyobj_zpos_hi
        ror
        sta     INWK+2
        sta     INWK+5
        jsr     L7366
        lda     $95
        and     #$07
        ora     #$81
        sta     polyobj_zpos_hi
        lda     $97
        and     #$03
        sta     INWK+2
        sta     INWK+1
        lda     #$00
        sta     polyobj_roll
        sta     polyobj_pitch
        lda     #$81
        jsr     L7545
L73CD   lda     displayed_screen
        bne     L73F3
L73D1   ldy     $e2
@L73D3  jsr     GetRandom
        ora     #$08
        sta     SCRNHOLE5+4,y
        sta     $b4
        jsr     GetRandom
        sta     $06c8,y
        sta     $6e
        jsr     GetRandom
        sta     $06e2,y
        sta     $6f
        jsr     L4EDC
        dey
        bne     @L73D3
L73F3   ldx     #$00
@L73F5  lda     PLAYER_STATE,x
        beq     @L741D
        bmi     @L741A
        sta     $b8
        jsr     GetInfo
        ldy     #$1f
@L7403  lda     (polyobj_ptr),y
        sta     polyobj_xpos_lo,y
        dey
        bpl     @L7403
        stx     $b0
        jsr     SCAN
        ldx     $b0
        ldy     #$1f
        lda     (polyobj_ptr),y
        and     #$a7
        sta     (polyobj_ptr),y
@L741A  inx
        bne     @L73F5
@L741D  ldx     #$00
        stx     $91
        dex
        stx     xcoords
        stx     ycoords
L7428   ldy     #$c7
        lda     #$00
@L742C  sta     $0600,y
        dey
        bne     @L742C
        dey
        sty     $d3
        rts

        !byte   $60

L7437   dex
        rts

L7439   inx
        beq     L7437
L743C   dec     $d6
        php
        bne     @L7443
        inc     $d6
@L7443  plp
        rts

L7445   jsr     @L74A4
        lda     PLAYER_STATE+11
        bne     @L747E
        jsr     L8274
        jmp     @L7481

@L7453  asl
        tax
        lda     #$00
        ror
        tay
        lda     #$14
        sta     $ad
        txa
        jsr     L60CE
        ldx     $31
        tya
        bmi     @L7469
        ldy     #$00
        rts

@L7469  ldy     #$ff
        txa
        eor     #$ff
        tax
        inx
@L7470  rts

@L7471  ldx     #$08
@L7473  lda     data_buffer+37,x
        sta     $38,x
        dex
        bpl     @L7473
        jmp     L8283

@L747E  jsr     @L7471
@L7481  lda     $6e
        jsr     @L7453
        txa
        adc     #$c3
        sta     $02dd
        lda     $6f
        jsr     @L7453
        stx     $d0
        lda     #$94
        sbc     $d0
        sta     $02de
        lda     #$60
        ldx     $70
        bpl     @L74A1
        lsr
@L74A1  sta     L4543
@L74A4  lda     L4543
        beq     @L7470
        sta     $b4
        lda     $02de
        ldx     $02dd
        jmp     DrawStar

L74B4   sta     $d0
        ldx     #$00
        ldy     #$08
        lda     (polyobj_ptr),y
        bmi     @L74CD
        lda     $d4
        sbc     $d0
        bcc     @L74C7
        sta     $d4
        rts

@L74C7  ldx     #$00
        stx     $d4
        bcc     @L74DA

@L74CD  lda     $d5
        sbc     $d0
        bcc     @L74D6
        sta     $d5
        rts

@L74D6  ldx     #$00
        stx     $d5
@L74DA  adc     $d6
        sta     $d6
        beq     @L74E2
        bcs     @L74E5
@L74E2  jmp     GameOver

@L74E5  jsr     MakeNoise2
        jmp     OUCH

L74EB   lda     data_buffer+1,x
        sta     $38,x
        lda     data_buffer+2,x
        tay
        and     #$7f
        sta     $39,x
        tya
        and     #$80
        sta     $3a,x
        rts

L74FE   jsr     LA019
        ldx     #$81
        stx     polyobj_attack
        ldx     #$00
        stx     polyobj_pitch
        stx     $30
        stx     PLAYER_STATE+1
        dex
        stx     polyobj_roll
        ldx     #$0a
        jsr     L75DD
        jsr     L75DD
        jsr     L75DD
        lda     saved_station_addr
        sta     station_addr
        lda     saved_station_addr+1
        sta     station_addr+1
        lda     $02f2
        cmp     #$0a
        bcc     @L753B
        lda     dodo_addr
        sta     station_addr
        lda     dodo_addr+1
        sta     station_addr+1
@L753B  lda     #$00
        sta     tmp_ptr2
        lda     #$06
        sta     tmp_ptr2+1
        lda     #$02
L7545   sta     $d0
        ldx     #$00
@L7549  lda     PLAYER_STATE,x
        beq     @L7555
        inx
        cpx     #$08
        bcc     @L7549
@L7553  clc
@L7554  rts

@L7555  jsr     GetInfo
        lda     $d0        ;ship type
        bmi     @L75AE
        asl
        tay
        lda     hull_addr_hi,y
        beq     @L7553
        sta     hull_ptr+1
        lda     hull_addr_lo,y
        sta     hull_ptr
        cpy     #$04
        beq     @L759E
        ldy     #$05
        lda     (hull_ptr),y
        sta     $06
        lda     $02f3
        sec
        sbc     $06
        sta     tmp_ptr2
        lda     $02f4
        sbc     #$00
        sta     tmp_ptr2+1
        lda     tmp_ptr2
        sbc     polyobj_ptr
        tay
        lda     tmp_ptr2+1
        sbc     polyobj_ptr+1
        bcc     @L7554
        bne     @L7594
        cpy     #$25
        bcc     @L7554
@L7594  lda     tmp_ptr2
        sta     $02f3
        lda     tmp_ptr2+1
        sta     $02f4
@L759E  ldy     #$0e
        lda     (hull_ptr),y
        sta     $2f
        ldy     #$13       ;00LLLMMM laser|missile from hull
        lda     (hull_ptr),y
        and     #$07       ;lower 3 bits are number of missiles
        sta     polyobj_vis
        lda     $d0        ;get ship type
@L75AE  sta     PLAYER_STATE,x
        tax
        bmi     @L75C6
        cpx     #$0f
        beq     @L75C0
        cpx     #$03
        bcc     @L75C3
        cpx     #$0b
        bcs     @L75C3
@L75C0  inc     PLAYER_STATE+42
@L75C3  inc     PLAYER_STATE+9,x
@L75C6  ldy     $d0
        lda     hull_NEWB-1,y
        and     #$6f
        ora     $30
        sta     $30
        ldy     #$24
@L75D3  lda     polyobj_xpos_lo,y
        sta     (polyobj_ptr),y
        dey
        bpl     @L75D3
        sec
        rts

L75DD   lda     polyobj_xpos_lo,x
        eor     #$80
        sta     polyobj_xpos_lo,x
        inx
        inx
        rts

L75E6   ldx     #$ff
L75E8   stx     missile_thing
        ldx     missile_armed_flag
        jsr     DrawIndicator
        sty     PLAYER_STATE+48
        rts

        !byte   $04
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   $00

L75F9   lda     polyobj_xpos_lo
        sta     $31
        lda     INWK+1
        sta     $32
        lda     INWK+2
        jsr     L78E3
        bcs     @L7630
        lda     $7a
        adc     #$80
        sta     $38
        txa
        adc     #$00
        sta     $39
        lda     polyobj_ypos_lo
        sta     $31
        lda     INWK+4
        sta     $32
        lda     INWK+5
        eor     #$80
        jsr     L78E3
        bcs     @L7630
        lda     $7a
        adc     #$44
        sta     $46
        txa
        adc     #$00
        sta     $47
        clc
@L7630  rts

L7631   lda     $b8        ;ship type
        lsr                ;bit 0 -> carry
        bcs     @L7639     ;sun has bit 0 set
        jmp     DrawSunOrPlanet ;wipe planet

@L7639  jmp     L785B      ;wipe sun

; Draw planet or sun.
; 
; BBC .PLANET (flight code).
Planet  lda     polyobj_zpos_hi
        cmp     #$30
        bcs     L7631      ;far away, branch
        ora     polyobj_zpos_mi
        beq     L7631      ;very close, branch
        jsr     L75F9      ;"Project K+INWK(x,y)/z to K3,K4 for center to screen"
        bcs     L7631
        lda     #$60       ;radius hi
        sta     $32
        lda     #$00       ;radius lo
        sta     $31
        jsr     L6143      ;"divide 3bytes by 2, K = P(2).A/INWK_z"
        lda     $7b
        beq     @L765E
        lda     #$f8
        sta     $7a
@L765E  lda     $b8        ;ship type
        lsr                ;sun has bit 0 set
        bcc     @Planet    ;planet
        jmp     L767B      ;sun

@Planet jsr     DrawSunOrPlanet
        jmp     L77A0

L766C   jmp     L785B

L766F   txa
        eor     #$ff
        clc
        adc     #$01
        tax
L7676   lda     #$ff
        jmp     L76C3

L767B   lda     #$14
        sta     $35
        lda     #$01
        sta     $d3
        jsr     L78A9
        bcs     L766C
        lda     #$00
        ldx     $7a
        cpx     #$60
        rol
        cpx     #$28
        rol
        cpx     #$10
        rol
        sta     $bd
        lda     $cc
        ldx     $33
        bne     @L76A7
        cmp     $32
        bcc     @L76A7
        lda     $32
        bne     @L76A7
        lda     #$01
@L76A7  sta     $bb
        lda     $cc
        sec
        sbc     $46
        tax
        lda     #$00
        sbc     $47
        bmi     L766F
        bne     @L76BF
        inx
        dex
        beq     L7676
        cpx     $7a
        bcc     L76C3
@L76BF  ldx     $7a
        lda     #$00
L76C3   stx     .data_ptr
        sta     .data_ptr+1
        lda     $7a
        jsr     L5F32
        sta     $c7
        lda     $31
        sta     $c6
        ldy     $cc
        lda     $64
        sta     $62
        lda     $65
        sta     $63
@L76DC  cpy     $bb
        beq     @L76EB
        lda     $0600,y
        beq     @L76E8
        jsr     L4EC6
@L76E8  dey
        bne     @L76DC
@L76EB  lda     .data_ptr
        jsr     L5F32
        sta     $d0
        lda     $c6
        sec
        sbc     $31
        sta     $ad
        lda     $c7
        sbc     $d0
        sta     $ae
        sty     $6f
        jsr     TwoByteSqrt
        ldy     $6f
        jsr     GetRandom
        and     $bd
        clc
        adc     $ad
        bcc     @L7712
        lda     #$ff
@L7712  ldx     $0600,y
        sta     $0600,y
        beq     @L7764
        lda     $64
        sta     $62
        lda     $65
        sta     $63
        txa
        jsr     L7878
        lda     $6e
        sta     $60
        lda     $70
        sta     $61
        lda     $38
        sta     $62
        lda     $39
        sta     $63
        lda     $0600,y
        jsr     L7878
        bcs     @L7749
        lda     $70
        ldx     $60
        stx     $70
        sta     $60
        jsr     DrawHorizLine
@L7749  lda     $60
        sta     $6e
        lda     $61
        sta     $70
@L7751  jsr     DrawHorizLine
@L7754  dey
        beq     @L7796
        lda     .data_ptr+1
        bne     @L7778
        dec     .data_ptr
        bne     @L76EB
        dec     .data_ptr+1
@L7761  jmp     @L76EB

@L7764  ldx     $38
        stx     $62
        ldx     $39
        stx     $63
        jsr     L7878
        bcc     @L7751
        lda     #$00
        sta     $0600,y
        beq     @L7754

@L7778  ldx     .data_ptr
        inx
        stx     .data_ptr
        cpx     $7a
        bcc     @L7761
        beq     @L7761
        lda     $64
        sta     $62
        lda     $65
        sta     $63
@L778B  lda     $0600,y
        beq     @L7793
        jsr     L4EC6
@L7793  dey
        bne     @L778B
@L7796  clc
        lda     $38
        sta     $64
        lda     $39
        sta     $65
L779F   rts

L77A0   jsr     L78A9
        bcs     L779F
        lda     #$00
        sta     xcoords
        ldx     $7a
        lda     #$08
        cpx     #$08
        bcc     @L77B8
        lsr
        cpx     #$3c
        bcc     @L77B8
        lsr
@L77B8  sta     $bf
L77BA   ldx     #$ff
        stx     $bc
        inx
        stx     $bd
@L77C1  lda     $bd
        jsr     FMLTU2
        ldx     #$00
        stx     $d0
        ldx     $bd
        cpx     #$21
        bcc     @L77DD
        eor     #$ff
        adc     #$00
        tax
        lda     #$ff
        adc     #$00
        sta     $d0
        txa
        clc
@L77DD  adc     $38
        sta     $9c
        lda     $39
        adc     $d0
        sta     $9d
        lda     $bd
        clc
        adc     #$10
        jsr     FMLTU2
        tax
        lda     #$00
        sta     $d0
        lda     $bd
        adc     #$0f
        and     #$3f
        cmp     #$21
        bcc     @L780B
        txa
        eor     #$ff
        adc     #$00
        tax
        lda     #$ff
        adc     #$00
        sta     $d0
        clc
@L780B  jsr     L4F8B
        cmp     #$41
        bcs     @L7815
        jmp     @L77C1

@L7815  clc
        rts

; This is called by the code that draws big circles (sun / planet).
DrawSunOrPlanet
        ldy     xcoords
        bne     @L7851
@Loop   cpy     $91
        bcs     @L7851
        lda     ycoords,y
        cmp     #$ff
        beq     @L7842
        sta     $71
        lda     xcoords,y
        sta     $70
        jsr     DrawLine
        iny
        lda     lcoord_swap_flag
        bne     @Loop
        lda     $70
        sta     $6e
        lda     $71
        sta     $6f
        jmp     @Loop

@L7842  iny
        lda     xcoords,y
        sta     $6e
        lda     ycoords,y
        sta     $6f
        iny
        jmp     @Loop

@L7851  lda     #$01
        sta     $91
        lda     #$ff
        sta     xcoords
L785A   rts

L785B   lda     $d3
        bmi     L785A
        lda     $64
        sta     $62
        lda     $65
        sta     $63
        ldy     #$87
@L7869  lda     $0600,y
        beq     @L7871
        jsr     L4EC6
@L7871  dey
        bne     @L7869
        dey
        sty     $d3
        rts

L7878   sta     $d0
        clc
        adc     $62
        sta     $70
        lda     $63
        adc     #$00
        bmi     @L78A2
        beq     @L788B
        lda     #$ff
        sta     $70
@L788B  lda     $62
        sec
        sbc     $d0
        sta     $6e
        lda     $63
        sbc     #$00
        bne     @L789A
        clc
        rts

@L789A  bpl     @L78A2
        lda     #$00
        sta     $6e
        clc
        rts

@L78A2  lda     #$00
        sta     $0600,y
        sec
        rts

L78A9   lda     $38
        clc
        adc     $7a
        lda     $39
        adc     #$00
        bmi     L78E1
        lda     $38
        sec
        sbc     $7a
        lda     $39
        sbc     #$00
        bmi     @L78C1
        bne     L78E1
@L78C1  lda     $46
        clc
        adc     $7a
        sta     $32
        lda     $47
        adc     #$00
        bmi     L78E1
        sta     $33
        lda     $46
        sec
        sbc     $7a
        tax
        lda     $47
        sbc     #$00
        bmi     L7906
        bne     L78E1
        cpx     $cc
        rts

L78E1   sec
        rts

L78E3   jsr     L6143
        lda     $7d
        and     #$7f
        ora     $7c
        bne     L78E1
        ldx     $7b
        cpx     #$04
        bcs     L7907
        lda     $7d
        bpl     L7907
        lda     $7a
        eor     #$ff
        adc     #$01
        sta     $7a
        txa
        eor     #$ff
        adc     #$00
        tax
L7906   clc
L7907   rts

L7908   jsr     GetInput
        cmp     #$59
        beq     L7907
        cmp     #$4e
        bne     L7908
        clc
        rts

; 
; Processes all input.  Flight controls update appropriate values in zero page. 
; Non-flight keys are returned in the caller.
; 
; On exit:
;   A-reg: non-flight key hit, or $00 if none
; 
GetGameInput
        lda     displayed_screen ;looking at space?
        bne     @L791E     ;no, branch
        jsr     HandleFlightInput
        txa
        rts

@L791E  jsr     HandleFlightInput
        lda     ptb_joy_enab
        beq     @L7937
        lda     pitch_velocity
        jsr     @L7968
        tay
        lda     roll_velocity
        eor     #$ff
        jsr     @L7968
        tax
        lda     input_raw_key
        rts

@L7937  lda     #$00
        sta     cmd_fire_mssl
        sta     cmd_local_jump
        lda     input_raw_key
        ldx     #$00
        ldy     #$00
        cmp     #$08
        beq     @L794B
        cmp     #$4a
        bne     @L794C
@L794B  dex
@L794C  cmp     #$15
        beq     @L7954
        cmp     #$4b
        bne     @L7955
@L7954  inx
@L7955  cmp     #$0a
        beq     @L795D
        cmp     #$4d
        bne     @L795E
@L795D  dey
@L795E  cmp     #$0b
        beq     @L7966
        cmp     #$49
        bne     @L7967
@L7966  iny
@L7967  rts

@L7968  lsr
        lsr
        lsr
        lsr
        lsr
        adc     #$00
        sbc     #$03
        rts

L7972   lda     $31
        sta     $02f3
        lda     $32
        sta     $02f4
        rts

L797D   ldx     $b0
        jsr     @L79D6
        ldx     $b0
        jmp     L47B2

@L7987  jsr     ZeroInfo
        jsr     L7428
        sta     PLAYER_STATE+1
        sta     PLAYER_STATE+11
        jsr     LA019
        lda     #$06
        sta     INWK+5
        lda     #$81
        jmp     L7545

@L799F  ldx     #$ff
@L79A1  inx
        lda     PLAYER_STATE,x
        beq     L7972
        cmp     #$01
        bne     @L79A1
        txa
        asl
        tay
        lda     L4E7E,y
        sta     $0a
        lda     L4E7F,y
        sta     $0b
        ldy     #$20
        lda     ($0a),y
        bpl     @L79A1
        and     #$7f
        lsr
        cmp     $c0
        bcc     @L79A1
        beq     @L79D0
        sbc     #$01
        asl
        ora     #$80
        sta     ($0a),y
        bne     @L79A1

@L79D0  lda     #$00
        sta     ($0a),y
        beq     @L79A1

@L79D6  stx     $c0
        lda     missile_thing
        cmp     $c0
        bne     @L79E8
        ldy     #$08
        jsr     L75E6
        lda     #$c8       ;"Target Lost"
        jsr     PrintMessageBriefly
@L79E8  ldy     $c0
        ldx     PLAYER_STATE,y
        cpx     #$02
        beq     @L7987
        cpx     #$1f
        bne     @L7A00
        lda     $028f
        ora     #$02
        sta     $028f
        inc     kill_score+1
@L7A00  cpx     #$0f
        beq     @L7A0C
        cpx     #$03
        bcc     @L7A0F
        cpx     #$0b
        bcs     @L7A0F
@L7A0C  dec     PLAYER_STATE+42
@L7A0F  dec     PLAYER_STATE+9,x
        ldx     $c0
        ldy     #$05
        lda     (hull_ptr),y
        ldy     #$21
        clc
        adc     (polyobj_ptr),y
        sta     $31
        iny
        lda     (polyobj_ptr),y
        adc     #$00
        sta     $32
@L7A26  inx
        lda     PLAYER_STATE,x
        sta     PLAYER_STATE-1,x
        bne     @L7A32
        jmp     @L799F

@L7A32  asl
        tay
        lda     hull_addr_lo,y
        sta     $0a
        lda     hull_addr_hi,y
        sta     $0b
        ldy     #$05
        lda     ($0a),y
        sta     $d0
        lda     $31
        sec
        sbc     $d0
        sta     $31
        lda     $32
        sbc     #$00
        sta     $32
        txa
        asl
        tay
        lda     L4E7E,y
        sta     $0a
        lda     L4E7F,y
        sta     $0b
        ldy     #$24
        lda     ($0a),y
        sta     (polyobj_ptr),y
        dey
        lda     ($0a),y
        sta     (polyobj_ptr),y
        dey
        lda     ($0a),y
        sta     $7b
        lda     $32
        sta     (polyobj_ptr),y
        dey
        lda     ($0a),y
        sta     $7a
        lda     $31
        sta     (polyobj_ptr),y
        dey
@L7A7C  lda     ($0a),y
        sta     (polyobj_ptr),y
        dey
        bpl     @L7A7C
        lda     $0a
        sta     polyobj_ptr
        lda     $0b
        sta     polyobj_ptr+1
        ldy     $d0
@L7A8D  dey
        lda     ($7a),y
        sta     ($31),y
        tya
        bne     @L7A8D
        beq     @L7A26

L7A97   ldx     ship_state2
        dex
        bne     @L7AAB
        lda     $0290
        cmp     #$90
        bne     @L7AAB
        lda     $0291
        cmp     #$21
        beq     @L7AAC
@L7AAB  clc
@L7AAC  rts

; C64 _83ca "clear ships slots and some other data?"
ClearStuff
        jsr     ZeroPlayerState ;leaves $00 in A-reg
        ldx     #$06
@L7AB2  sta     $66,x      ;pitch, roll, ...
        dex
        bpl     @L7AB2
        stx     ptb_joy_y_flip ;store $FF
        txa
        sta     docked_flag
        ldx     #$02
@L7ABF  sta     $d4,x
        dex
        bpl     @L7ABF
RES2    lda     #$0c       ;BBC .RES2
        sta     $e2
        ldx     #$ff
        stx     xcoords
        stx     ycoords
        stx     missile_thing
        lda     #$80
        sta     pitch_velocity
        sta     $6c
        sta     $a7
        asl
        sta     $66
        sta     $67
        sta     $6d
        sta     $a8
        sta     $b6
        lda     #$03
        sta     player_speed
        sta     $b9
        sta     $6b
        lda     #$00
        sta     $cb
        lda     #$87
        sta     $cc
        lda     PLAYER_STATE+11
        beq     @L7AFD
        jsr     LA019
@L7AFD  lda     ecm_active_flag
        beq     @L7B04
        jsr     L9512
@L7B04  jsr     L73F3
        jsr     ZeroPlayerState
        lda     #$5f
        sta     $02f3
        lda     #$0b
        sta     $02f4
ZeroInfo
        ldy     #$24       ;BBC ZINF
        lda     #$00
@L7B18  sta     polyobj_xpos_lo,y
        dey
        bpl     @L7B18
        lda     #$60
        sta     $1e
        sta     $22
        ora     #$80
        sta     polyobj_mox2_hi
        rts

L7B29   ldx     #$04
@L7B2B  cpx     missile_armed_flag
        beq     @L7B39
        ldy     #$00
        jsr     DrawIndicator
        dex
        bne     @L7B2B
        rts

@L7B39  ldy     #$08
        jsr     DrawIndicator
        dex
        bne     @L7B39
        rts

L7B42   lda     displayed_screen
        bne     @L7B54
        lda     in_flight_msg_token
        jsr     PrintMessageBriefly
        lda     #$00
        sta     PLAYER_STATE+54
        jmp     L7BC7

@L7B54  jsr     ClearLines
        jmp     L7BC7

L7B5A   jsr     ZeroInfo
        jsr     GetRandom
        sta     $06
        and     #$80
        sta     INWK+2
        txa
        and     #$80
        sta     INWK+5
        lda     #$19
        sta     INWK+1
        sta     INWK+4
        sta     polyobj_zpos_mi
        txa
        cmp     #$f5
        rol
        ora     #$c0
        sta     polyobj_attack
SaveScramble
        clc
; 
; Generate a random number.
; 
; Used for various things, notably the programmatically generated planet data.
; 
; On exit:
;   A-reg: random number (0-255)
; 
GetRandom
        lda     rng_state
        rol
        tax
        adc     rng_state+2
        sta     rng_state
        stx     rng_state+2
        lda     rng_state+1
        tax
        adc     rng_state+3
        sta     rng_state+1
        stx     rng_state+3
        rts

L7B90   jsr     GetRandom
        lsr
        sta     polyobj_attack
        sta     polyobj_roll
        rol     polyobj_vis
        and     #$1f
        ora     #$10
        sta     polyobj_vertex_lo
        jsr     GetRandom
        bmi     @L7BAF
        lda     polyobj_attack
        ora     #$c0       ;active | target
        sta     polyobj_attack
        ldx     #$10
        stx     $30
@L7BAF  and     #$02
        adc     #$0b
        cmp     #$0f
        beq     L7BBA
        jsr     L7545
L7BBA   jsr     UpdateShipControls
        dec     PLAYER_STATE+54
        beq     L7B42
        bpl     L7BC7
        inc     PLAYER_STATE+54
L7BC7   dec     $b6
        beq     @L7BCE
@MainLoop_jmp
        jmp     MainLoop

@L7BCE  lda     witch_space_flag ;in witch space?
        bne     @MainLoop_jmp ;yes, skip this
        jsr     GetRandom
        cmp     #$23
        bcs     @L7C2F
        lda     PLAYER_STATE+42
        cmp     #$03
        bcs     @L7C2F
        jsr     ZeroInfo
        lda     #$26
        sta     polyobj_zpos_mi
        jsr     GetRandom
        sta     polyobj_xpos_lo
        stx     polyobj_ypos_lo
        and     #$80
        sta     INWK+2
        txa
        and     #$80
        sta     INWK+5
        rol     INWK+1
        rol     INWK+1
        jsr     GetRandom
        bvs     L7B90
        ora     #$6f
        sta     polyobj_roll
        lda     PLAYER_STATE+11
        bne     @L7C2F
        txa
        bcs     @L7C15
        and     #$1f
        ora     #$10
        sta     polyobj_vertex_lo
        bcc     @L7C19

@L7C15  ora     #$7f
        sta     polyobj_pitch
@L7C19  jsr     GetRandom
        cmp     #$fc
        bcc     @L7C26
        lda     #$0f
        sta     polyobj_attack
        bne     @L7C2C

@L7C26  cmp     #$0a
        and     #$01
        adc     #$05
@L7C2C  jsr     L7545
@L7C2F  lda     PLAYER_STATE+11
        beq     @L7C37
@L7C34  jmp     MainLoop

@L7C37  jsr     CountIllegalCargo
        asl
        ldx     PLAYER_STATE+25
        beq     @L7C43
        ora     player_fug_inno
@L7C43  sta     $d0
        jsr     L7B5A
        cmp     #$88
        beq     @L7C72
        cmp     $d0
        bcs     @L7C55
        lda     #$10
        jsr     L7545
@L7C55  lda     PLAYER_STATE+25
        bne     @L7C34
        dec     PLAYER_STATE+53
        bpl     @L7C34
        inc     PLAYER_STATE+53
        lda     $028f
        and     #$0c
        cmp     #$08
        bne     @L7C75
        jsr     GetRandom
        cmp     #$c8
        bcc     @L7C75
@L7C72  jsr     L6D6F
@L7C75  jsr     GetRandom
        ldy     $02f1
        beq     @L7C88
        cmp     #$5a
        bcs     @L7C34
        and     #$07
        cmp     $02f1
        bcc     @L7C34
@L7C88  jsr     L7B5A
        cmp     #$64
        bcs     @L7CC5
        inc     PLAYER_STATE+53
        and     #$03
        adc     #$18
        tay
        jsr     L7A97
        bcc     @L7CAD
        lda     #$f9
        sta     polyobj_attack
        lda     $028f
        and     #$03
        lsr
        bcc     @L7CAD
        ora     PLAYER_STATE+40
        beq     @L7CBD
@L7CAD  lda     #$04
        sta     $30
        jsr     GetRandom
        cmp     #$c8
        rol
        ora     #$c0
        sta     polyobj_attack
        tya
        !byte   $2c
@L7CBD  lda     #$1f
        jsr     L7545
        jmp     MainLoop

@L7CC5  and     #$03
        sta     PLAYER_STATE+53
        sta     $b5
@L7CCC  jsr     GetRandom
        sta     $d0
        jsr     GetRandom
        and     $d0
        and     #$07
        adc     #$11
        jsr     L7545
        dec     $b5
        bpl     @L7CCC
; 
; This appears to be the main game play loop while in space.
; 
; The BBC Micro and C64 versions are similar but different.  For example, the
; C64 version has additional code to handle "trumbles" (a non-infringing species
; of tribble).
; 
MainLoop
        ldx     #$ff       ;reset the stack pointer
        txs
        ldx     player_laser_temp ;cool the lasers
        beq     @Cold
        dec     player_laser_temp
@Cold   ldx     main_dec2_thing
        beq     @Was0
        dex
        beq     @Was1
        dex
@Was1   stx     main_dec2_thing
@Was0   jsr     DrawHud
        lda     displayed_screen ;viewing space?
        beq     @NoDelay   ;yes
        and     ptb_pausecmd_x
        lsr                ;check the low bit (set for planet info screen?)
        bcs     @NoDelay   ;set, don't delay
        ldy     #$02       ;this seems to slow things down when you're in
        jsr     LongDelay  ; space but not looking at space
@NoDelay
        jsr     GetGameInput
FromGameInit
        jsr     HandleNonFlightKey
        lda     docked_flag ;docked?
        beq     @CheckStuff ;no, check some stuff
        jmp     MainLoop

@CheckStuff
        jmp     L7BBA

HandleNonFlightKey
        cmp     #'9'
        bne     @Not9
        jmp     ShipStatusScreen

@Not9   cmp     #'5'
        bne     @Not5
        jmp     GalacticChartScreen

@Not5   cmp     #'6'
        bne     @Not6
        jmp     LocalChartScreen

@Not6   cmp     #'7'
        bne     @Not7
        jsr     L6A9E
        jmp     SystemDataScreen

@Not7   cmp     #'0'
        bne     @Not0
        jmp     CargoListScreen

@Not0   cmp     #'8'
        bne     @Not8
        jmp     LocalMarketScreen

@Not8   cmp     #'1'
        bne     @Not1
        jmp     LaunchOrLook

@Not1   bit     docked_flag ;are we docked?
        bpl     @NotDocked ;no, skip these
        cmp     #'4'
        bne     @Not4
        jmp     DockEquipShip ;equip ship

@Not4   cmp     #'2'
        bne     @Not2
        jmp     DockBuyCargo

@Not2   cmp     #'I'
        bne     @L7D6F
        jsr     FileAccessMenu
        bcc     @L7D6C
        jmp     L7EF8

@L7D6C  jmp     L7F2D

@L7D6F  cmp     #'3'
        bne     @L7D8D
        jmp     DockSellCargo

@NotDocked
        cmp     #'2'
        beq     @View2
        cmp     #'3'
        beq     @View3
        cmp     #'4'
        bne     @L7D8D
        ldx     #$03
        !byte   $2c
@View3  ldx     #$02
        !byte   $2c
@View2  ldx     #$01
        jmp     SetViewDirection

@L7D8D  lda     input_raw_key
        cmp     #'H'
        bne     @NotH
        jmp     L6B46      ;hyperspace

@NotH   cmp     #'G'
        bne     @NotG
        jmp     L6B46      ;intergalactic travel

@NotG   cmp     #'D'
        beq     ShowDistToPlanet
        cmp     #'F'
        bne     @NotF
; 'F': find planet by name (while looking at charts)
        lda     docked_flag
        beq     L7DEE
        lda     displayed_screen
        and     #$c0
        beq     L7DEE
        jmp     L5765

@NotF   sta     $06
        lda     displayed_screen
        and     #$c0
        beq     @L7DD0
        lda     $69
        bne     @L7DD0
        lda     $06
        cmp     #$4f
        bne     @L7DCD
        jsr     L6960
        jsr     L638B
        jmp     L6960

@L7DCD  jsr     L6937
@L7DD0  lda     $69
        beq     L7DEE
        dec     $68
        bne     L7DEE
        ldx     $69
        dex
        jsr     L6C03
        lda     #$05
        sta     $68
        ldx     $69
        jsr     L6C03
        dec     $69
        bne     L7DEE
        jmp     L6DB0

L7DEE   rts

; 'D' key hit (distance to system under crosshairs)
ShowDistToPlanet
        lda     displayed_screen
        and     #$c0
        beq     L7DEE
        jsr     L705B
        jsr     PrintSelPlanet
        lda     #$80
        sta     text_mod_flags
        lda     #$0c
        jsr     PrintChar
        jmp     L6445

; BBC .BAD "Legal status from Cargo scan"
CountIllegalCargo
        lda     player_cargo+3 ;slaves
        clc
        adc     player_cargo+6 ;narcotics
        asl                ;double penalty for slaves/narcotics
        adc     player_cargo+10 ;firearms
        rts

L7E13   lda     #$e0
L7E15   cmp     INWK+1
        bcc     @L7E1F
        cmp     INWK+4
        bcc     @L7E1F
        cmp     polyobj_zpos_mi
@L7E1F  rts

L7E20   ora     INWK+1
        ora     INWK+4
        ora     polyobj_zpos_mi
        rts

L7E27   !byte   $00
        !byte   $ce
        !byte   $27
        !byte   $7e
        !byte   $a2
        !byte   $ff
        !byte   $9a
        !byte   $20
        !byte   $67
        !byte   $82
        !byte   $a8
        !byte   $a9
        !byte   $07
        !byte   $20
        !xor    $80 {
        !text   "f H1}Px"
        }
        !byte   $4c
        !byte   $de
        !byte   $7e

GameOver
        ldy     #$d2
        jsr     L9571
        jsr     RES2
        asl     player_speed
        asl     player_speed
        lda     #$00
        jsr     PrintFlightHud
        jsr     L73D1
        lda     #$0c
        sta     text_hposn
        sta     text_vposn
        lda     #$92       ;"GAME OVER"
        jsr     PrintCannedMsg
@L7E5E  jsr     L7B5A
        lsr
        lsr
        sta     polyobj_xpos_lo
        ldy     #$00
        sty     INWK+1
        sty     INWK+4
        sty     polyobj_zpos_mi
        sty     polyobj_attack
        dey
        sty     $b6
        eor     #$2a
        sta     polyobj_ypos_lo
        ora     #$50
        sta     polyobj_zpos_lo
        txa
        and     #$8f
        sta     polyobj_roll
        ldy     #$40
        sty     main_dec2_thing
        sec
        ror
        and     #$87
        sta     polyobj_pitch
        ldx     #$05
        lda     plate_addr+1
        beq     @L7E94
        bcc     @L7E94
        dex
@L7E94  jsr     L5C29
        jsr     GetRandom
        and     #$80
        ldy     #$1f
        sta     (polyobj_ptr),y
        lda     PLAYER_STATE+4
        beq     @L7E5E
        lda     #$00
        sta     player_speed
        jsr     UpdateShipControls
@L7EAC  jsr     UpdateShipControls
        dec     main_dec2_thing
        bne     @L7EAC
        jmp     RestartGame

saved_station_addr
        !byte   $88
        !byte   $88

; 
; Finishes initialization and falls into the welcome screen.
; 
InitGame
        ldx     #$1d
        lda     #$00
@Loop   sta     L4543,x    ;zero out $4543-4560
        dex                ;(pause-mode toggles + other stuff)
        bpl     @Loop
        lda     station_addr
        sta     saved_station_addr
        lda     station_addr+1
        sta     saved_station_addr+1
        jsr     InitPlayerData ;reset player save data to default
        ldx     #$ff       ;reset system stack
        txs
        jsr     ClearStuff
; 
; Welcome screen.  We get here after initialization completes, or when ESC is
; hit in the pause menu.
; 
RestartGame
        ldx     #$ff
        txs
        jsr     RES2
        jsr     ResetInputs
        lda     #$03
        sta     text_hposn
        ldx     #11        ;11 == Cobra Mk III
        lda     #$06       ;"Load New Commander (Y/N)?"
        ldy     #$fa
        jsr     GameStartScreen
        cpx     #'Y'
        bne     L7EF8
        jsr     L7F36
        jsr     FileAccessMenu
L7EF8   jsr     L7F36
        jsr     L7B29
        lda     #$07       ;"Press space or fire, commander."
        ldx     #17        ;17 = Sidewinder
        ldy     #$4b
        jsr     GameStartScreen
        jsr     L638B
        jsr     L6A9E
        jsr     L6BF8
        ldx     #$05
@L7F12  lda     $92,x
        sta     $02f5,x
        dex
        bpl     @L7F12
        inx
        stx     PLAYER_STATE+53
        lda     $d7
        sta     $02ef
        lda     $d9
        sta     $02f2
        lda     $d8
        sta     $02f1
L7F2D   lda     #$ff
        sta     docked_flag
        lda     #$39
        jmp     FromGameInit

L7F36   ldx     #$54
@L7F38  lda     commander_name-1,x
        sta     $0286,x
        dex
        bne     @L7F38
        stx     displayed_screen
@L7F43  jsr     L8029
        cmp     scramble_thing+1
        bne     @L7F43
        eor     #$a9
        tax
        lda     ship_state1
        cpx     scramble_thing-1
        beq     @L7F58
        ora     #$80
@L7F58  ora     #$08
        sta     ship_state1
        jsr     L8037
        cmp     scramble_thing
        bne     @L7F43
        rts

GameStartScreen
        sty     intro_parameter ;Z distance?
        pha                ;docked string token; save for later
        stx     $b8        ;ship type
        lda     #$ff
        sta     unused_thing1
        jsr     ClearStuff
        lda     #$00
        sta     unused_thing1
        jsr     ResetInputs
        lda     #$0d
        jsr     PrintFlightHud
        lda     #$00
        sta     displayed_screen
        lda     #$60
        sta     polyobj_mox2_hi
        lda     #$60
        sta     polyobj_zpos_mi
        ldx     #$7f
        stx     polyobj_roll
        stx     polyobj_pitch
        inx
        stx     text_mod_flags ;set to $80
        lda     $b8
        jsr     L7545
        lda     #$06
        sta     text_hposn
        lda     #$1e       ;"---- E L I T E ----"
        jsr     PrintTokFF
        lda     #$0a
        jsr     PrintChar
        lda     #$06
        sta     text_hposn
        lda     ptb_pausecmd_x ;check pause-X flag
        beq     @NotX      ;not set, branch
        lda     #$0d       ;"By D.Braben & I.Bell"
        jsr     PrintDockedStr ;draw a second copy of author's names
@NotX   lda     L7E27
        beq     @L7FD1
        inc     L7E27
        lda     #$07
        sta     text_hposn
        lda     #$09
        sta     text_vposn
        ldy     #$00
@loop   jsr     OutputChar
        iny
        lda     ($fd),y
        bne     @loop
@L7FD1  ldy     #$00
        sty     player_speed
        sty     ptb_joy_enab
        lda     #14
        sta     text_vposn
        lda     #1
        sta     text_hposn
        pla                ;A=reg = $06 or $07
        jsr     PrintDockedStr
        lda     #$03
        sta     text_hposn
        lda     #$0c       ;"(C) D.Braben & I.Bell 1985"
        jsr     PrintDockedStr
        lda     #$0c
        sta     $be
        lda     #$05
        sta     $b6
; Animate the ship.
@WaitLoop
        lda     polyobj_zpos_mi
        cmp     #$01
        beq     @NoDec
        dec     polyobj_zpos_mi
@NoDec  jsr     MVEIT
        ldx     intro_parameter
        stx     polyobj_zpos_lo
        lda     $b6        ;?
        and     #$03       ;?
        lda     #$00
        sta     polyobj_xpos_lo
        sta     polyobj_ypos_lo
        jsr     DrawObject
        jsr     CheckForInput
        dec     $b6
        lda     BUTN0      ;check to see if either joystick button was hit
        ora     BUTN1
        and     joystick_found_nr ;ignore if joystick not found earlier (which it never
        bmi     EnableJoystick ; (is, because the code to find it isn't called)
        bcc     @WaitLoop  ;no key hit, loop
        rts

EnableJoystick
        dec     ptb_joy_enab
        rts

L8029   ldx     #$49
        clc
        txa
@L802D  adc     save_game_state,x
        eor     save_game_state+1,x
        dex
        bne     @L802D
        rts

L8037   ldx     #$49
        clc
        txa
@L803B  stx     $d0
        eor     $d0
        ror
        adc     save_game_state,x
        eor     save_game_state+1,x
        dex
        bne     @L803B
        rts

InitPlayerData
        ldy     #97
@Loop   lda     commander_jameson,y
        sta     commander_name,y
        dey
        bpl     @Loop
        ldy     #$07
        sty     LoadSavedGame-1
        rts

L805B   ldx     #$00
@L805D  lda     INWK+5,x
        cmp     #$0d
        beq     @L806B
        sta     disk_filename,x
        inx
        cpx     #$07
        bcc     @L805D
@L806B  lda     #$20
@L806D  sta     disk_filename,x
        inx
        cpx     #$1e
        bcc     @L806D
        rts

L8076   ldx     #$07
        lda     L81E9
        sta     LoadSavedGame-1
@L807E  lda     INWK+5,x
        sta     commander_name,x
        dex
        bpl     @L807E
L8086   ldx     #$07
@L8088  lda     commander_name,x
        sta     INWK+5,x
        dex
        bpl     @L8088
        rts

L8091   ldx     #$04
@L8093  lda     L4D80,x
        sta     polyobj_xpos_lo,x
        dex
        bpl     @L8093
        lda     #$07
        sta     max_cmdr_name_len
        lda     #$08
        jsr     PrintDockedStr
        jsr     InputName
        lda     #$09
        sta     max_cmdr_name_len
        tya
        beq     L8086
        sty     L81E9
        rts

; 
; Enter a name, for the commander or a planet.
; 
InputName
        ldy     #$08
        jsr     LongDelay
        jsr     ClearKbdStrb
        ldy     #$00
@Loop   jsr     GetInput1
        cmp     #$0d       ;enter
        beq     @Accept
        cmp     #$1b       ;esc
        beq     @Cancel
        cmp     #$7f       ;delete
        beq     @Backspace
        cpy     max_cmdr_name_len
        bcs     @BadKey
        cmp     cmdr_name_min_char
        bcc     @BadKey
        cmp     cmdr_name_max_char
        bcs     @BadKey
        sta     INWK+5,y
        iny
        !byte   $2c
@BadKey lda     #$07       ;bell
@L80E3  jsr     OutputChar
        bcc     @Loop      ;(always?)
@Accept sta     INWK+5,y
        lda     #$0c
        jmp     OutputChar

@Cancel sec
        rts

@Backspace
        tya                ;already at start of name?
        beq     @BadKey    ;yes, just beep
        dey
        lda     #$7f       ;print a DEL
        bne     @L80E3     ;(always)

        !byte   $11
        !byte   $00
max_cmdr_name_len
        !byte   $09        ;max 9 chars
cmdr_name_min_char
        !byte   '!'
cmdr_name_max_char
        !byte   '{'

PrintDiskTape
        lda     #$03       ;"tape"
        clc
        adc     ptb_pausecmd_t ;--> 3 or 2
        jmp     PrintDockedStr

PrintTapeDisk
        lda     #$02       ;"disk"
        sec
        sbc     ptb_pausecmd_t ;--> 2 or 3
        jmp     PrintDockedStr

ZeroPlayerState
        ldx     #55
        lda     #$00
@Loop   sta     PLAYER_STATE,x
        dex
        bpl     @Loop
        rts

        !byte   $60
        !byte   $a2
        !byte   $0c
        !byte   $20
        !byte   $23
        !byte   $81
        !byte   $ca
        !byte   $a0
        !byte   $00
        !byte   $84
        !byte   $0a
        !byte   $a9
        !byte   $00
        !byte   $86
        !byte   $0b
        !byte   $91
        !byte   $0a
        !byte   $c8
        !byte   $d0
        !byte   $fb
        !byte   $60

        !zone   Z007731
.txt_ptr =      $6e
FileAccessMenu
        lda     #$01       ;"disk access menu ..."
        jsr     PrintDockedStr
        jsr     GetInput
        cmp     #'1'
        beq     LoadGame
        cmp     #'2'
        beq     SaveGame
        cmp     #'3'
        bne     @Return
        lda     #$e0       ;reset to default game
        jsr     PrintDockedStr
        jsr     L7908
        bcc     @Return
        jsr     InitPlayerData
        jmp     L7F36

@Return clc
        rts

LoadGame
        jsr     L8091
        jsr     LoadSavedGame
        jsr     L8076
        sec
        rts

SaveGame
        jsr     L8091
        jsr     L8076
        lsr     $02d8
        lda     #$04
        jsr     PrintDockedStr
        ldx     #$4c
@Loop   lda     $028f,x
        sta     save_game_state+1,x
        dex
        bpl     @Loop
        jsr     L8037
        sta     scramble_thing
        jsr     L8029
        sta     scramble_thing+1
        pha
        ora     #$80
        sta     $7a
        eor     ship_state1
        sta     $7c
        eor     player_credits+2
        sta     $7b
        eor     #$5a
        eor     kill_score+1
        sta     $7d
        clc
        jsr     PrintNumber
        jsr     PrintFF
        jsr     PrintFF
        pla
        eor     #$a9
        sta     scramble_thing-1
        jsr     L805B
        ldy     #$4c
@Loop1  lda     save_game_state+1,y
        sta     scram_save_data+20,y
        dey
        bpl     @Loop1
        jsr     DiskSaveGame
        bcs     SaveFail
        jsr     L7F36
        jsr     GetInput
        clc
        rts

SaveFail
        asl                ;error code in A-reg (1-5)
        tax
        lda     disk_err_msgs-2,x
        sta     .txt_ptr
        lda     disk_err_msgs-1,x
        sta     .txt_ptr+1
        ldy     #$00
@Loop   lda     (.txt_ptr),y
        beq     @StrEnd
        jsr     PrintChar
        iny
        bne     @Loop
@StrEnd jsr     Noise1
        jsr     GetInput
        jmp     FileAccessMenu

L81E9   !byte   $07
        !byte   $07

LoadSavedGame
        jsr     L805B
        jsr     DiskLoadGame
        bcs     SaveFail
        jsr     UnscrambleSaveData
        lda     scram_save_data+20
        bmi     @L8208
        ldy     #$4c
@Loop   lda     scram_save_data+20,y
        sta     save_game_state+1,y
        dey
        bpl     @Loop
        sec
        rts

@L8208  lda     #$09
        jsr     PrintDockedStr
        jsr     GetInput
        jmp     FileAccessMenu

T8213   !text   "DISK WRITE PROTECTED",$00
T8228   !text   "DISK FULL",$00
T8232   !text   "CATALOG FULL",$00
T823F   !text   "DISK I/O ERROR",$00
T824E   !text   "FILE NOT FOUND",$00
disk_err_msgs
        !word   T8213
        !word   T8228
        !word   T8232
        !word   T823F
        !word   T824E
        !byte   $60
        !byte   $60

ResetInputs
        lda     #$00
        ldx     #$10
@L826D  sta     input_raw_key,x
        dex
        bpl     @L826D
        rts

        !byte   $60

L8274   ldx     #$00
        jsr     L74EB
        ldx     #$03
        jsr     L74EB
        ldx     #$06
        jsr     L74EB
L8283   lda     $38
        ora     $3b
        ora     $3e
        ora     #$01
        sta     $41
        lda     $39
        ora     $3c
        ora     $3f
@L8293  asl     $41
        rol
        bcs     L82A6
        asl     $38
        rol     $39
        asl     $3b
        rol     $3c
        asl     $3e
        rol     $3f
        bcc     @L8293
L82A6   lda     $39
        lsr
        ora     $3a
        sta     .txt_ptr
        lda     $3c
        lsr
        ora     $3d
        sta     .txt_ptr+1
        lda     $3f
        lsr
        ora     $40
        sta     $70
L82BB   lda     .txt_ptr
        jsr     L5F30
        sta     $ae
        lda     $31
        sta     $ad
        lda     .txt_ptr+1
        jsr     L5F30
        sta     $d0
        lda     $31
        adc     $ad
        sta     $ad
        lda     $d0
        adc     $ae
        sta     $ae
        lda     $70
        jsr     L5F30
        sta     $d0
        lda     $31
        adc     $ad
        sta     $ad
        lda     $d0
        adc     $ae
        sta     $ae
        jsr     TwoByteSqrt
        lda     .txt_ptr
        jsr     L8681
        sta     .txt_ptr
        lda     .txt_ptr+1
        jsr     L8681
        sta     .txt_ptr+1
        lda     $70
        jsr     L8681
        sta     $70
        rts

; 
; Reads a paddle.
; 
; On entry:
;   X-reg: paddle # (0 or 1)
; 
; On exit:
;   X-reg: (unchanged)
;   Y-reg: paddle reading
;   A-reg: paddle reading (possibly modified)
; 
ReadPaddle
        lda     PADDL0,x
        bmi     ReadPaddle ;let it settle
        ldy     PTRIG      ;reset the timer
        ldy     #$00
        nop
        nop
@Loop   lda     PADDL0,x   ;test current value
        bpl     @Done      ;done
        iny
        bne     @Loop
        dey
@Done   tya
        eor     ptb_joy_axis_flip ;invert both axes
        rts

; 
; Checks for input from the keyboard and/or joystick.
; 
; On exit:
;   $80: key hit, or $00 if none
;   A-reg/X-reg: same as $80
;   $81-90: bool 00/ff: command N issued
;   P-flags set (N/V/Z) according to Acc, (C) set if key was hit
; 
CheckForInput
        tya
        pha
        jsr     ResetInputs
        clc
        lda     KBD        ;was a key hit?
        bpl     @NoKeyHit  ;no, check the next thing
        bit     KBDSTRB    ;clear input
        and     #$7f       ;clear hi bit
        sta     input_raw_key ;save for later
        ldx     #$10
@CheckKey
        cmp     flight_key_cmds-1,x ;does it match one of the flight control keys?
        bne     @NotMatch  ;no, branch
        dec     input_raw_key,x ;set $8x to $FF to indicate key hit
@NotMatch
        dex
        bne     @CheckKey
        sec                ;set carry to indicate key hit
@NoKeyHit
        lda     ptb_joy_enab
_set_by_init
        bpl     @NoPaddle  ;init code changes branch to $30==$8373
        ldx     computer_dock_flag ;is computer driving the ship?
        bne     @NoPaddle  ;yup, ignore the joystick
        jsr     ReadPaddle ;read X axis
        eor     #$ff       ;invert
        sta     roll_velocity
        inx                ;X-reg=1
        jsr     ReadPaddle ;read Y axis
        eor     ptb_joy_y_flip
        sta     pitch_velocity
@NoPaddle
        lda     #$ff
        bit     BUTN0      ;button 0 hit?
        bpl     @NotBtn0   ;nope
        bit     BUTN1      ;button 1 hit?
        bpl     @OnlyBtn1  ;nope
        sta     cmd_throttle_down ;both buttons == throttle down
        bmi     @Cont      ;(always)

@OnlyBtn1
        sta     cmd_fire_laser ;fire lasers
@NotBtn0
        bit     BUTN1      ;button 1 hit?
        bpl     @Cont
        sta     cmd_throttle_up ;increase throttle
@Cont   lda     displayed_screen ;something that disables commands?
@NoJoyBranchHere
        beq     @Done      ;not set
        lda     #$00       ;clear all commands
        sta     cmd_energy_bomb
        sta     cmd_escape_cap
        sta     cmd_targ_mssl
        sta     cmd_unarm_mssl
        sta     cmd_fire_mssl
        sta     cmd_ecm
        sta     cmd_local_jump
        sta     cmd_dock_on
        sta     cmd_dock_off
@Done   pla
        tay
        lda     input_raw_key
        tax
        rts

LocalJump
        ldx     PLAYER_STATE+42
        lda     PLAYER_STATE+2,x
        ora     PLAYER_STATE+11
        ora     witch_space_flag
        bne     @L83E2
        ldy     data_buffer+8
        bmi     @L83AA
        tay
        jsr     L5261
        cmp     #$02
        bcc     @L83E2
@L83AA  ldy     data_buffer+45
        bmi     @L83B8
        ldy     #$25
        jsr     L525F
        cmp     #$02
        bcc     @L83E2
@L83B8  lda     #$81
        sta     $af
        sta     $ae
        sta     $31
        lda     data_buffer+8
        jsr     ADD
        sta     data_buffer+8
        lda     data_buffer+45
        jsr     ADD
        sta     data_buffer+45
        lda     #$01
        sta     displayed_screen
        sta     $b6
        lsr
        sta     PLAYER_STATE+53
        ldx     PLAYER_STATE+49
        jmp     SetViewDirection

@L83E2  jmp     Noise1

        !fill   1,$60
; 
; Flight-control keys.  When pressed, the corresponding zero-page location is
; set to true.
; 
flight_key_cmds
        !byte   '/'        ;$81 throttle down
        !byte   ' '        ;$82 throttle up
        !byte   ','        ;$83 roll left
        !byte   '.'        ;$84 roll right
        !byte   'X'        ;$85 pitch down
        !byte   'S'        ;$86 pitch up
        !byte   'A'        ;$87 fire lasers
        !byte   'B'        ;$88 energy bomb
        !byte   $1b        ;$89 escape capsule
        !byte   'T'        ;$8a target missile
        !byte   'U'        ;$8b un-arm missile
        !byte   'M'        ;$8c fire missile
        !byte   'E'        ;$8d ECM
        !byte   'J'        ;$8e in-system jump
        !byte   'C'        ;$8f docking computer on
        !byte   'P'        ;$90 docking computer off
        !hex    a2002c00c01004ca2c10c08a6060 ;unreferenced code?

; 
; Check to see if a pause-mode key has been hit.  If so, update the toggle
; value.
; 
; On entry:
;   Y-reg: entry to check (0-8)
; 
CheckPauseToggles
        txa
        cmp     pause_key_cmds,y ;does it match the Nth entry?
        bne     @Bail      ;no
        lda     ptb_kbd_dampening,y ;yes, flip the state of that variable
        eor     #$ff
        sta     ptb_kbd_dampening,y
        bpl     @SwitchOff
        jsr     PrintBell  ;chirp
@SwitchOff
        jsr     PrintBell  ;twice when enabled
        tya                ;preserve Y-reg
        pha
        ldy     #$14
        jsr     LongDelay
        pla                ;restore Y-reg
        tay
@Bail   rts

        !byte   $60

HandleFlightInput
        jsr     CheckForInput
        lda     computer_dock_flag
        beq     @L8487
        jsr     ZeroInfo
        lda     #$60
        sta     polyobj_mox2_hi
        ora     #$80
        sta     $22
        sta     $b8
        lda     player_speed
        sta     polyobj_vertex_lo
        jsr     L5A50
        lda     polyobj_vertex_lo
        cmp     #$16
        bcc     @L8449
        lda     #$16
@L8449  sta     player_speed
        lda     #$ff
        ldx     #$01
        ldy     $28
        beq     @L8459
        bmi     @L8457
        ldx     #$02
@L8457  sta     input_raw_key,x
@L8459  lda     #$80
        ldx     #$03
        asl     polyobj_roll
        beq     @L8473
        bcc     @L8465
        ldx     #$04
@L8465  bit     polyobj_roll
        bpl     @L846F
        lda     #$40
        sta     roll_velocity
        lda     #$00
@L846F  sta     input_raw_key,x
        lda     roll_velocity
@L8473  sta     roll_velocity
        lda     #$80
        ldx     #$05
        asl     polyobj_pitch
        beq     @L8485
        bcs     @L8481
        ldx     #$06
@L8481  sta     input_raw_key,x
        lda     pitch_velocity
@L8485  sta     pitch_velocity
@L8487  ldx     roll_velocity
        lda     #$14
        ldy     cmd_roll_left
        beq     @L8492
        jsr     L61F1
@L8492  ldy     cmd_roll_right
        beq     @L8499
        jsr     REDU2
@L8499  stx     roll_velocity
        ldx     pitch_velocity
        ldy     cmd_pitch_down
        beq     @L84A4
        jsr     REDU2
@L84A4  ldy     cmd_pitch_up
        beq     @L84AB
        jsr     L61F1
@L84AB  stx     pitch_velocity
        ldx     input_raw_key
        stx     input_raw_key
        cpx     #'='       ;pause key?
        bne     @Done
@PauseMode
        jsr     Delay
        jsr     CheckForInput
        cpx     #'Q'       ;is it a 'Q'?
        bne     @L84C6
        ldx     #$ff       ;yes, disable sound
        stx     sound_disab_flag
        ldx     #'Q'       ;continue with 'Q'
@L84C6  ldy     #$00
@TogLoop
        jsr     CheckPauseToggles ;DAXFYJKUT
        iny
        cpy     #$09
        bne     @TogLoop
        cpx     #'S'       ;is it 'S'?
        bne     @L84D9
        lda     #$00       ;yes, enable sound
        sta     sound_disab_flag
@L84D9  cpx     #$1b       ;ESC?
        bne     @L84E0
        jmp     RestartGame

@L84E0  cpx     #'-'       ;unpause?
        bne     @PauseMode ;no, keep going
@Done   rts

GetInput1
        sty     $b1
GetInput
        ldy     #$02
        jsr     LongDelay
        jsr     CheckForInput
        bne     GetInput
@L84F1  jsr     CheckForInput
        beq     @L84F1
        ldy     $b1
        tax
Return2 rts

L84FA   stx     PLAYER_STATE+54
        pha
        lda     in_flight_msg_token
        jsr     L8553
        pla
PrintMessageBriefly
        pha
        lda     #$0f
        ldx     displayed_screen
        beq     @L8512
        jsr     ClearLines
        lda     #$19
        !byte   $2c
@L8512  sta     text_vposn
        ldx     #$00
        stx     text_mod_flags
        lda     $ce
        sta     text_hposn
        pla
        ldy     #$14
        cpx     PLAYER_STATE+54
        bne     L84FA
        sty     PLAYER_STATE+54
        sta     in_flight_msg_token
        lda     #$c0
        sta     txt_buffer_flag
        lda     $0278
        lsr
        lda     #$00
        bcc     @L8539
        lda     #$0a
@L8539  sta     txt_buffer_index
        lda     in_flight_msg_token
        jsr     PrintFlightToken
        lda     #$20
        sec
        sbc     txt_buffer_index
        lsr
        sta     $ce
        sta     text_hposn
        jsr     ClearBufferFlag
        lda     in_flight_msg_token
L8553   jsr     PrintFlightToken
        lsr     $0278
        bcc     Return2
        lda     #$fd       ;"Destroyed"
        jmp     PrintFlightToken

; Shield depleted, losing cargo / equipment.
OUCH    jsr     GetRandom
        bmi     Return2    ;50% chance of nothing lost
        cpx     #22        ;max equipment
        bcs     Return2    ;number too high, nothing lost
        lda     player_cargo,x ;check cargo
        beq     Return2    ;don't have that, nothing lost
        lda     PLAYER_STATE+54 ;"delay printing already going on"
        bne     Return2
        ldy     #$03
        sty     $0278
        sta     player_cargo,x ;A-reg=0 from above
        cpx     #17        ;cargo is 0-16, ECM=17 is first equipment
        bcs     @EquipLost
        txa                ;cargo is lost; get item name
        adc     #$d0       ;token $d0 = "Food"
        jmp     PrintMessageBriefly

@EquipLost
        beq     @LostEcm   ;X=17, ECM lost
        cpx     #18        ;is it a fuel scoop?
        beq     @LostScoop ;yes
        txa
        adc     #$5d       ;$5d+19 = $70 "Escape Pod"
        jmp     PrintMessageBriefly

@LostEcm
        lda     #$6c       ;"E.C.M. System"
        jmp     PrintMessageBriefly

@LostScoop
        lda     #$6f       ;"Fuel Scoops"
        jmp     PrintMessageBriefly

; Market price info.
; 
; BBC: "base_price, gradient sign+5bits, base_quantity, mask, units 2bits"
MarketData
        !hex    13820601   ;Food
        !hex    14810a03   ;Textiles
        !hex    41830207   ;Radioactives
        !hex    2885e21f   ;Slaves
        !hex    5385fb0f   ;Liquor/Wines
        !hex    c4083603   ;Luxuries
        !hex    eb1d0878   ;Narcotics
        !hex    9a0e3803   ;Computers
        !hex    75062807   ;Machinery
        !hex    4e01111f   ;Alloys
        !hex    7c0d1d07   ;Firearms
        !hex    b089dc3f   ;Furs
        !hex    20813503   ;Minerals
        !hex    61a14207   ;Gold
        !hex    aba2371f   ;Platinum
        !hex    2dc1fa0f   ;Gem-Stones
        !hex    350fc007   ;Alien Items

L85DF   tya
        ldy     #$02
        jsr     L86AE
        sta     $20
        jmp     L8627

L85EA   tax
        lda     .txt_ptr+1
        and     #$60
        beq     L85DF
        lda     #$02
        jsr     L86AE
        sta     $1e
        jmp     L8627

L85FB   lda     $16
        sta     .txt_ptr
        lda     $18
        sta     .txt_ptr+1
        lda     polyobj_mox2_hi
        sta     $70
        jsr     L82BB
        lda     .txt_ptr
        sta     $16
        lda     .txt_ptr+1
        sta     $18
        lda     $70
        sta     polyobj_mox2_hi
        ldy     #$04
        lda     .txt_ptr
        and     #$60
        beq     L85EA
        ldx     #$02
        lda     #$00
        jsr     L86AE
        sta     $1c
L8627   lda     $1c
        sta     .txt_ptr
        lda     $1e
        sta     .txt_ptr+1
        lda     $20
        sta     $70
        jsr     L82BB
        lda     .txt_ptr
        sta     $1c
        lda     .txt_ptr+1
        sta     $1e
        lda     $70
        sta     $20
        lda     $18
        sta     $ad
        lda     $20
        jsr     MULT12
        ldx     polyobj_mox2_hi
        lda     $1e
        jsr     TIS1
        eor     #$80
        sta     $22
        lda     $1c
        jsr     MULT12
        ldx     $16
        lda     $20
        jsr     TIS1
        eor     #$80
        sta     $24
        lda     $1e
        jsr     MULT12
        ldx     $18
        lda     $1c
        jsr     TIS1
        eor     #$80
        sta     $26
        lda     #$00
        ldx     #$0e
@L867A  sta     $15,x
        dex
        dex
        bpl     @L867A
        rts

L8681   tay
        and     #$7f
        cmp     $ad
        bcs     @L86A8
        ldx     #$fe
        stx     $d0
@L868C  asl
        cmp     $ad
        bcc     @L8693
        sbc     $ad
@L8693  rol     $d0
        bcs     @L868C
        lda     $d0
        lsr
        lsr
        sta     $d0
        lsr
        adc     $d0
        sta     $d0
        tya
        and     #$80
        ora     $d0
        rts

@L86A8  tya
        and     #$80
        ora     #$60
        rts

L86AE   sta     $33
        lda     $16,x
        sta     $ad
        lda     $1c,x
        jsr     MULT12
        ldx     $16,y
        stx     $ad
        lda     $001c,y
        jsr     MAD
        stx     $31
        ldy     $33
        ldx     $16,y
        stx     $ad
        eor     #$80
        sta     $32
        eor     $ad
        and     #$80
        sta     $d0
        lda     #$00
        ldx     #$10
        asl     $31
        rol     $32
        asl     $ad
        lsr     $ad
@L86E1  rol
        cmp     $ad
        bcc     @L86E8
        sbc     $ad
@L86E8  rol     $31
        rol     $32
        dex
        bne     @L86E1
        lda     $31
        ora     $d0
        rts

        !byte   $02
        !byte   $0f
        !text   "12345678901234567"

DrawShipAsPoint
        jsr     L75F9
        ora     $39
        bne     @L8728
        lda     $46
        cmp     #$86
        bcs     @L8728
        jsr     @L8731
        lda     $46
        clc
        adc     #$01
        jsr     @L8731
        lda     #$08
        ora     polyobj_vis
        sta     polyobj_vis
        jmp     DrawDot

@L8728  lda     #$f7
        and     polyobj_vis
        sta     polyobj_vis
        jmp     DrawDot

@L8731  sta     .txt_ptr+1
        sta     $71
        lda     $38
        sta     .txt_ptr
        clc
        adc     #$03
        bcc     @L8740
        lda     #$ff
@L8740  sta     $70
        jmp     DrawTwoThings

; "Q=SQR(RQ) two-byte square root, R is hi, Q is lo"
        !zone   Z007d45
.XX16   =       $48
.XX15   =       $6e
.q_val  =       $ad
.r_val  =       $ae
.s_val  =       $af
.t_val  =       $d0
TwoByteSqrt
        ldy     .r_val
        lda     .q_val
        sta     .s_val
        ldx     #$00
        stx     .q_val
        lda     #$08
        sta     .t_val
@L8753  cpx     .q_val
        bcc     @L8765
        bne     @L875D
        cpy     #$40
        bcc     @L8765
@L875D  tya
        sbc     #$40
        tay
        txa
        sbc     .q_val
        tax
@L8765  rol     .q_val
        asl     .s_val
        tya
        rol
        tay
        txa
        rol
        tax
        asl     .s_val
        tya
        rol
        tay
        txa
        rol
        tax
        dec     .t_val
        bne     @L8753
        rts

; "R=A*256/Q   byte from remainder of division"
; The BBC implementation was iterative.  It appears to have been replaced with a
; table lookup.
BFRDIV  cmp     .q_val     ;"is A >= Q ?"
        bcs     @TooBig    ;"if yes, answer too big for 1 byte, R=$FF"
        sta     $ca
        tax
        beq     @L879E
        lda     math_table2,x
        ldx     .q_val
        sec
        sbc     math_table2,x
        ldx     $ca
        lda     math_table1,x
        ldx     .q_val
        sbc     math_table1,x
        bcs     @TooBig
        tax
        lda     math_table3,x
@L879E  sta     .r_val
        rts

; Original implementation of BFRDIV, not referenced.
@unref_BFRDIV
        bcs     @TooBig
        ldx     #$fe
        stx     .r_val
@L87A7  asl
        bcs     @L87B5
        cmp     .q_val
        bcc     @L87B0
        sbc     .q_val
@L87B0  rol     .r_val
        bcs     @L87A7
        rts

@L87B5  sbc     .q_val
        sec
        rol     .r_val
        bcs     @L87A7
        lda     .r_val
        rts

@TooBig lda     #$ff
        sta     .r_val
        rts

; Single-byte add/subtract.
; 
; .LL38 BADD "(Sign S)A = R + Q*(Sign from A^S)"
; 
; On entry:
;   $AE: R
;   $AD: Q
;   A-reg: sign bit to apply to Q
; 
; On exit:
;   A-reg: result
;   $AF: S (sign bit of result)
ByteAddSub
        eor     .s_val     ;check A^S (subtracting neg value -> add)
        bmi     @Subtract  ;negative, do subtraction
        lda     .q_val     ;add values; sign in S is already correct
        clc
        adc     .r_val
        rts

@Subtract
        lda     .r_val     ;compute R-Q
        sec
        sbc     .q_val
        bcc     @FixSign   ;went negative
        clc
        rts

@FixSign
        pha
        lda     .s_val
        eor     #$80
        sta     .s_val
        pla
        eor     #$ff
        adc     #$01
        rts

; 
; Computes the dot product of two vectors.  Mathematically, the dot product of
; [A,B,C] and [X,Y,Z] is A*X + B*Y + C*Z.  The value is the cosine of the angle
; between the vectors.
; 
; "XX12=XX15.XX16  each vector is 16-bit x,y,z"
; 
DotProduct
        ldx     #$00
        ldy     #$00
@L87E8  lda     .XX15
        sta     .q_val
        lda     .XX16,x
        jsr     FMLTU
        sta     .t_val
        lda     .XX15+1
        eor     .XX16+1,x
        sta     .s_val
        lda     .XX15+2
        sta     .q_val
        lda     .XX16+2,x
        jsr     FMLTU
        sta     .q_val
        lda     .t_val
        sta     .r_val
        lda     .XX15+3
        eor     .XX16+3,x
        jsr     ByteAddSub
        sta     .t_val
        lda     .XX15+4
        sta     .q_val
        lda     .XX16+4,x
        jsr     FMLTU
        sta     .q_val
        lda     .t_val
        sta     .r_val
        lda     .XX15+5
        eor     .XX16+5,x
        jsr     ByteAddSub
        sta     $0074,y
        lda     .s_val
        sta     $0075,y
        iny
        iny
        txa
        clc
        adc     #$06
        tax
        cmp     #$11
        bcc     @L87E8
        rts

HandlePlanet
        jmp     Planet

        !zone   Z007e3e
.INWK_xlo =     $0c
.INWK_xhi =     $0d
.INWK_ylo =     $0f
.INWK_yhi =     $10
.INWK_zlo =     $12
.INWK_zhi =     $13
.polyobj_face_vis = $38
.face_ptr =     $5e
.normal_x =     $74
.nx_sign_flag = $75
.normal_y =     $76
.ny_sign_flag = $77
.normal_z =     $78
.nz_sign_flag = $79
.scale  =       $b2        ;XX17
.ship_type =    $b8
.xx4_visibility = $c0
.item_xcount =  $c1        ;BBC:XX20
.tmp    =       $d0
DrawObject
        lda     .ship_type ;ship type
        bmi     HandlePlanet ;planet has high bit set
        lda     #$1f
        sta     .xx4_visibility ;set visibility to max
        ldy     #$01
        sty     $c2
        dey                ;Y-reg=0
        lda     #$08
        bit     polyobj_vis
        bne     @L8854
        lda     #$00       ;visibility:display
        !byte   $2c
@L8854  lda     (tmp_ptr2),y
        sta     $c3
        lda     $30
        bmi     CheckVisDrawDot
        lda     #$20       ;mask bit 5 (exploding)
        bit     polyobj_vis
        bne     @Explode   ;bit 5 set, explosion ongoing
        bpl     @Explode   ;bit 7 clear, start blowing up
        ora     polyobj_vis
        and     #%00111111 ;visibility:(exploding|firing) ^ $FF
        sta     polyobj_vis
        lda     #$00
        ldy     #$1c
        sta     (polyobj_ptr),y
        ldy     #$1e
        sta     (polyobj_ptr),y
        jsr     CheckVisDrawDot
        ldy     #$01
        lda     #$12
        sta     (tmp_ptr2),y
        ldy     #$07       ;hull explosion count
        lda     (hull_ptr),y
        ldy     #$02
        sta     (tmp_ptr2),y
@L8885  iny
        jsr     GetRandom
        sta     (tmp_ptr2),y
        cpy     #$06       ;"bytes 3to6 = random bytes for seed"
        bne     @L8885
@Explode
        lda     polyobj_zpos_hi ;sign of Z coord
        bpl     ObjInFront
TestRemove
        lda     polyobj_vis
        and     #$20       ;ongoing explosion?
        beq     CheckVisDrawDot
        lda     polyobj_vis
        and     #$f7
        sta     polyobj_vis
        jmp     DoExplosion

CheckVisDrawDot
        lda     #$08
        bit     polyobj_vis
        beq     @L88AF
        eor     polyobj_vis
        sta     polyobj_vis
        jmp     DrawDot

@L88AF  rts

; Object in front of player (.LL10).
; (Looks like INWK has transformed center point of object?)
ObjInFront
        lda     .INWK_zhi
        cmp     #$c0       ;far in front?
        bcs     TestRemove ;test to remove object
        lda     .INWK_xlo
        cmp     .INWK_zlo
        lda     .INWK_xhi
        sbc     .INWK_zhi  ;gives angle to object
        bcs     TestRemove
        lda     .INWK_ylo
        cmp     .INWK_zlo
        lda     .INWK_yhi
        sbc     .INWK_zhi
        bcs     TestRemove
        ldy     #$06       ;+$06 gun vertex
        lda     (hull_ptr),y
        tax                ;vertex index in X-reg
        lda     #$ff       ;flag that vertex
        sta     BUFFER_0100,x
        sta     $0101,x
; Compute XX4 visibility.
        lda     .INWK_zlo  ;take Z value
        sta     .tmp       ;low in tmp, high in A-reg
        lda     .INWK_zhi
        lsr                ;divide by 4
        ror     .tmp
        lsr
        ror     .tmp
        lsr
        ror     .tmp
        lsr
        bne     @Far       ;still bits in high byte, it's far away
        lda     .tmp       ;only bits in low byte now
        ror                ;(plus one in the carry flag)
        lsr
        lsr
        lsr                ;8 shifts, /256, == high byte?
        sta     .xx4_visibility ;update visibility
        bpl     DrawWireframe ;(always)
@Far    ldy     #$0d       ;+13 LOD distance (becomes a dot)
        lda     (hull_ptr),y
        cmp     .INWK_zhi
        bcs     DrawWireframe
        lda     #$20       ;mask exploding bit
        and     polyobj_vis
        bne     DrawWireframe ;exploding do the draw
        jmp     DrawShipAsPoint ;too far, just draw a point

; "Draw wireframe (including nodes exploding)" (.LL17)
DrawWireframe
        ldx     #$05       ;"load rotmat into XX16"
@L8906  lda     $21,x
        sta     $48,x      ;"XX16,X"
        lda     $1b,x
        sta     $4e,x      ;"XX16+6,X"
        lda     $15,x
        sta     $54,x      ;"XX16+12,X"
        dex
        bpl     @L8906
        lda     #197       ;"comment here about NORM"
        sta     $ad
        ldy     #$10
@L891B  lda     $0048,y
        asl
        lda     $0049,y
        rol
        jsr     BFRDIV     ;R=A*256/197
        ldx     $ae
        stx     $48,y
        dey
        dey
        bpl     @L891B
        ldx     #$08       ;"load craft coords into XX18"
@L8930  lda     .INWK_xlo,x
        sta     $98,x
        dex
        bpl     @L8930
        lda     #$ff       ;"last normal is always visible"
        sta     $47
        ldy     #$0c       ;+$0c face count
        lda     polyobj_vis
        and     #$20       ;are we exploding (bit 5)?
        beq     ComputeVis ;no, not all faces are visible
        lda     (hull_ptr),y ;get face count * 4
        lsr                ;divide by 4
        lsr
        tax
        lda     #$ff       ;mark visible
@Loop   sta     .polyobj_face_vis,x ;on all faces
        dex
        bpl     @Loop
        inx
        stx     .xx4_visibility ;set to zero
DoTranspose
        jmp     TransposeMatrix

        !zone   Z007f55
.INWK_xlo =     $0c
.INWK_xhi =     $0d
.INWK_ylo =     $0f
.INWK_yhi =     $10
.INWK_zlo =     $12
.INWK_zhi =     $13
.polyobj_face_vis = $38
.face_ptr =     $5e
.scal_norm_x =  $6e
.scal_norm_y =  $70
.normal_x =     $74
.nx_sign_flag = $75
.normal_y =     $76
.ny_sign_flag = $77
.normal_z =     $78
.nz_sign_flag = $79
.x_lo   =       $98
.x_hi   =       $99
.y_lo   =       $9b
.y_hi   =       $9c
.z_lo   =       $9e
.z_hi   =       $9f
.scal_norm_z =  $ae
.s_val  =       $af
.scale  =       $b2        ;XX17
.ship_type =    $b8
.xx4_visibility = $c0
.item_xcount =  $c1        ;BBC:XX20
.tmp    =       $d0
ComputeVis
        lda     (hull_ptr),y ;Y-reg=$0c: face count * 4
        beq     DoTranspose ;no faces
        sta     .item_xcount
        ldy     #$12       ;+$12 "scaling of normals"
        lda     (hull_ptr),y ;normals scaled by 2^Q%
        tax
        lda     .z_hi      ;get z_hi
        tay                ;is high byte zero?
        beq     @ObjClose  ;yes, object close/small
@ScaleLoop
        inx
        lsr     .y_hi
        ror     .y_lo
        lsr     .x_hi
        ror     .x_lo
        lsr
        ror     .z_lo
        tay                ;have we reduced z_hi to 0?
        bne     @ScaleLoop ;no, keep going
@ObjClose
        stx     .scale
        lda     $a0
        sta     $73
        lda     .x_lo
        sta     .scal_norm_x
        lda     $9a
        sta     $6f
        lda     .y_lo
        sta     .scal_norm_y
        lda     $9d
        sta     $71
        lda     .z_lo
        sta     $72
        jsr     DotProduct
        lda     .normal_x
        sta     .x_lo
        lda     .nx_sign_flag
        sta     $9a
        lda     .normal_y
        sta     .y_lo
        lda     .ny_sign_flag
        sta     $9d
        lda     .normal_z
        sta     .z_lo
        lda     .nz_sign_flag
        sta     $a0
        ldy     #$04       ;+4 face data offset low byte
        lda     (hull_ptr),y
        clc
        adc     hull_ptr
        sta     .face_ptr
        ldy     #$11       ;+11 face data offset high byte
        lda     (hull_ptr),y
        adc     hull_ptr+1
        sta     .face_ptr+1
; Iterate through all normals (BBC .LL86).
        ldy     #$00
@FaceLoop
        lda     (.face_ptr),y ;get 1st byte (flags) from face data
        sta     .nx_sign_flag
        and     #%00011111 ;low 5 bits are the always-visible limit
        cmp     .xx4_visibility ;compare to distance
        bcs     @CheckNormVis ;cutoff >= dist; might not be visible; check normal
        tya                ;face entry offset
        lsr                ;divide by 4 to get face index
        lsr
        tax
        lda     #$ff
        sta     .polyobj_face_vis,x ;mark face as visible
        tya                ;advance to next face
        adc     #$04
        tay
        jmp     @NearEnd

@CheckNormVis
        lda     .nx_sign_flag ;unpack sign flags
        asl
        sta     .ny_sign_flag
        asl
        sta     .nz_sign_flag
        iny
        lda     (.face_ptr),y ;extract face normal vector
        sta     .normal_x
        iny
        lda     (.face_ptr),y
        sta     .normal_y
        iny
        lda     (.face_ptr),y
        sta     .normal_z
        ldx     .scale
        cpx     #$04
        bcc     @Small
        lda     .x_lo
        sta     .scal_norm_x
        lda     $9a
        sta     $6f
        lda     .y_lo
        sta     .scal_norm_y
        lda     $9d
        sta     $71
        lda     .z_lo
        sta     $72
        lda     $a0
        sta     $73
        jmp     @L8A73

@Ovflw  lsr     .x_lo
        lsr     .z_lo
        lsr     .y_lo
; Divide normal vector components by 4.
        ldx     #$01       ;scale=1
@Small  lda     .normal_x  ;BBC .LL92
        sta     .scal_norm_x
        lda     .normal_y
        sta     .scal_norm_y
        lda     .normal_z
        dex                ;scale--
        bmi     @ScaleDone ;scale done, branch
@DownShift
        lsr     .scal_norm_x
        lsr     .scal_norm_y
        lsr
        dex
        bpl     @DownShift
@ScaleDone
        sta     .scal_norm_z
        lda     .nz_sign_flag
        sta     .s_val
        lda     .z_lo
        sta     $ad
        lda     $a0
        jsr     ByteAddSub
        bcs     @Ovflw
        sta     $72
        lda     .s_val
        sta     $73
        lda     .scal_norm_x
        sta     .scal_norm_z
        lda     .nx_sign_flag
        sta     .s_val
        lda     .x_lo
        sta     $ad
        lda     $9a
        jsr     ByteAddSub
        bcs     @Ovflw
        sta     .scal_norm_x
        lda     .s_val
        sta     $6f
        lda     .scal_norm_y
        sta     .scal_norm_z
        lda     .ny_sign_flag
        sta     .s_val
        lda     .y_lo
        sta     $ad
        lda     $9d
        jsr     ByteAddSub
        bcs     @Ovflw
        sta     .scal_norm_y
        lda     .s_val
        sta     $71
; "calculate 3D dot product XX12 . XX15 for (x,y,z)" .LL89
@L8A73  lda     .normal_x
        sta     $ad
        lda     .scal_norm_x
        jsr     FMLTU      ;"A=A*Q/256unsg"
        sta     .tmp
        lda     .nx_sign_flag
        eor     $6f
        sta     .s_val
        lda     .normal_y
        sta     $ad
        lda     .scal_norm_y
        jsr     FMLTU
        sta     $ad
        lda     .tmp
        sta     .scal_norm_z
        lda     .ny_sign_flag
        eor     $71
        jsr     ByteAddSub
        sta     .tmp
        lda     .normal_z
        sta     $ad
        lda     $72
        jsr     FMLTU
        sta     $ad
        lda     .tmp
        sta     .scal_norm_z
        lda     $73
        eor     .nz_sign_flag
        jsr     ByteAddSub
        pha                ;"push xdot+ydot+zdot"
        tya
        lsr
        lsr
        tax                ;normal index
        pla
        bit     .s_val
        bmi     @L8ABE     ;"if -ve then keep acc"
        lda     #$00       ;"else face not visible"
@L8ABE  sta     .polyobj_face_vis,x
        iny
@NearEnd
        cpy     .item_xcount ;done with faces?  (BBC .LL88)
        bcs     TransposeMatrix
        jmp     @FaceLoop

TransposeMatrix
        ldy     $4a        ;transpose matrix (BBC .LL42)
        ldx     $4b
        lda     $4e
        sta     $4a
        lda     $4f
        sta     $4b
        sty     $4e
        stx     $4f
        ldy     $4c
        ldx     $4d
        lda     $54
        sta     $4c
        lda     $55
        sta     $4d
        sty     $54
        stx     $55
        ldy     $52
        ldx     $53
        lda     $56
        sta     $52
        lda     $57
        sta     $53
        sty     $56
        stx     $57
; Read vertices.
        !zone   Z0080f8
.INWK_xlo =     $0c
.INWK_xhi =     $0d
.INWK_ylo =     $0f
.INWK_yhi =     $10
.INWK_zlo =     $12
.INWK_zhi =     $13
.tmp    =       $31
.polyobj_face_vis = $38
.vertex_ptr =   $5e
.vertex_x =     $6e
.vx_sign_flag = $6f
.vertex_y =     $70
.vy_sign_flag = $71
.vertex_z =     $72
.vz_sign_flag = $73
.normal_x =     $74
.nx_sign_flag = $75
.normal_y =     $76
.ny_sign_flag = $77
.normal_z =     $78
.nz_sign_flag = $79
.x_lo   =       $98
.x_hi   =       $99
.y_lo   =       $9b
.y_hi   =       $9c
.z_lo   =       $9e
.z_hi   =       $9f
.scal_norm_z =  $ae
.s_val  =       $af
.count_v6 =     $b2
.ship_type =    $b8
.count  =       $bd        ;CNT
.xx4_visibility = $c0
.item_xcount =  $c1        ;BBC:XX20
.vertex_flags = $d0
        ldy     #$08       ;+8 number of vertices * 6
        lda     (hull_ptr),y
        sta     .item_xcount
        lda     hull_ptr   ;vertices start right after hull header
        clc
        adc     #20        ;which is 20 bytes
        sta     .vertex_ptr
        lda     hull_ptr+1
        adc     #$00
        sta     .vertex_ptr+1
        ldy     #$00
        sty     .count
L8B0F   sty     .count_v6
        lda     (.vertex_ptr),y
        sta     .vertex_x
        iny
        lda     (.vertex_ptr),y
        sta     .vertex_y
        iny
        lda     (.vertex_ptr),y
        sta     .vertex_z
        iny
        lda     (.vertex_ptr),y
        sta     .vertex_flags
        and     #%00011111 ;mask visibility
        cmp     .xx4_visibility ;is visible?
        bcc     @Next      ;no, skip it
        iny
        lda     (.vertex_ptr),y ;get first two faces
        sta     .tmp
        and     #$0f       ;face 1
        tax
        lda     .polyobj_face_vis,x ;face visibility index
        bne     @IsVisible ;vertex is visible if any face visible
        lda     .tmp       ;shift to get face 2
        lsr
        lsr
        lsr
        lsr
        tax
        lda     .polyobj_face_vis,x ;check visibility
        bne     @IsVisible
        iny
        lda     (.vertex_ptr),y ;get second pair of faces
        sta     .tmp
        and     #$0f       ;face 3
        tax
        lda     .polyobj_face_vis,x
        bne     @IsVisible
        lda     .tmp       ;face 4
        lsr
        lsr
        lsr
        lsr
        tax
        lda     .polyobj_face_vis,x
        bne     @IsVisible
@Next   jmp     UpdateCounts

@IsVisible
        lda     .vertex_flags ;.LL49
        sta     .vx_sign_flag
        asl
        sta     .vy_sign_flag
        asl
        sta     .vz_sign_flag
        jsr     DotProduct
        lda     INWK+2
        sta     .vertex_y
        eor     .nx_sign_flag
        bmi     @L8B80
        clc
        lda     .normal_x
        adc     .INWK_xlo
        sta     .vertex_x
        lda     .INWK_xhi
        adc     #$00
        sta     .vx_sign_flag
        jmp     @L8BA3

@L8B80  lda     .INWK_xlo
        sec
        sbc     .normal_x
        sta     .vertex_x
        lda     .INWK_xhi
        sbc     #$00
        sta     .vx_sign_flag
        bcs     @L8BA3
        eor     #$ff
        sta     .vx_sign_flag
        lda     #$01
        sbc     .vertex_x
        sta     .vertex_x
        bcc     @L8B9D
        inc     .vx_sign_flag
@L8B9D  lda     .vertex_y
        eor     #$80
        sta     .vertex_y
@L8BA3  lda     INWK+5
        sta     .vz_sign_flag
        eor     .ny_sign_flag
        bmi     @L8BBB
        clc
        lda     .normal_y
        adc     .INWK_ylo
        sta     .vy_sign_flag
        lda     .INWK_yhi
        adc     #$00
        sta     .vertex_z
        jmp     @L8BE0

@L8BBB  lda     .INWK_ylo
        sec
        sbc     .normal_y
        sta     .vy_sign_flag
        lda     .INWK_yhi
        sbc     #$00
        sta     .vertex_z
        bcs     @L8BE0
        eor     #$ff
        sta     .vertex_z
        lda     .vy_sign_flag
        eor     #$ff
        adc     #$01
        sta     .vy_sign_flag
        lda     .vz_sign_flag
        eor     #$80
        sta     .vz_sign_flag
        bcc     @L8BE0
        inc     .vertex_z
@L8BE0  lda     .nz_sign_flag
        bmi     @L8C2E
        lda     .normal_z
        clc
        adc     .INWK_zlo
        sta     .vertex_flags
        lda     .INWK_zhi
        adc     #$00
        sta     $ac
        jmp     @L8C4D

@L8BF4  ldx     $ad
        beq     @L8C14
        ldx     #$00
@L8BFA  lsr
        inx
        cmp     $ad
        bcs     @L8BFA
        stx     .s_val
        jsr     BFRDIV
        ldx     .s_val
        lda     .scal_norm_z
@L8C09  asl
        rol     $ac
        bmi     @L8C14
        dex
        bne     @L8C09
        sta     .scal_norm_z
        rts

@L8C14  lda     #$32
        sta     .scal_norm_z
        sta     $ac
        rts

@L8C1B  lda     #$80
        sec
        sbc     .scal_norm_z
        sta     BUFFER_0100,x
        inx
        lda     #$00
        sbc     $ac
        sta     BUFFER_0100,x
        jmp     @L8C8D

@L8C2E  lda     .INWK_zlo
        sec
        sbc     .normal_z
        sta     .vertex_flags
        lda     .INWK_zhi
        sbc     #$00
        sta     $ac
        bcc     @L8C45
        bne     @L8C4D
        lda     .vertex_flags
        cmp     #$04
        bcs     @L8C4D
@L8C45  lda     #$00
        sta     $ac
        lda     #$04
        sta     .vertex_flags
@L8C4D  lda     $ac
        ora     .vx_sign_flag
        ora     .vertex_z
        beq     @L8C64
        lsr     .vx_sign_flag
        ror     .vertex_x
        lsr     .vertex_z
        ror     .vy_sign_flag
        lsr     $ac
        ror     .vertex_flags
        jmp     @L8C4D

@L8C64  lda     .vertex_flags
        sta     $ad
        lda     .vertex_x
        cmp     $ad
        bcc     @L8C74
        jsr     @L8BF4
        jmp     @L8C77

@L8C74  jsr     BFRDIV
@L8C77  ldx     .count
        lda     .vertex_y
        bmi     @L8C1B
        lda     .scal_norm_z
        clc
        adc     #$80
        sta     BUFFER_0100,x
        inx
        lda     $ac
        adc     #$00
        sta     BUFFER_0100,x
@L8C8D  txa
        pha
        lda     #$00
        sta     $ac
        lda     .vertex_flags
        sta     $ad
        lda     .vy_sign_flag
        cmp     $ad
        bcc     @L8CB6
        jsr     @L8BF4
        jmp     @L8CB9

@L8CA3  lda     #$44
        clc
        adc     .scal_norm_z
        sta     BUFFER_0100,x
        inx
        lda     #$00
        adc     $ac
        sta     BUFFER_0100,x
        jmp     UpdateCounts

@L8CB6  jsr     BFRDIV
@L8CB9  pla
        tax
        inx
        lda     .vz_sign_flag
        bmi     @L8CA3
        lda     #$44
        sec
        sbc     .scal_norm_z
        sta     BUFFER_0100,x
        inx
        lda     #$00
        sbc     $ac
        sta     BUFFER_0100,x
UpdateCounts
        clc                ;BBC .LL50
        lda     .count     ;advance count by 4
        adc     #$04
        sta     .count
        lda     .count_v6  ;and other count by 6
        adc     #$06
        tay
        bcs     @L8CE5
        cmp     .item_xcount
        bcs     @L8CE5
        jmp     L8B0F

@L8CE5  lda     polyobj_vis ;display/exploding state|missiles
        and     #$20       ;check bit 5
        beq     @L8CF4     ;no explosion, branch
        lda     polyobj_vis
        ora     #$08       ;"set bit3 to erase old line"
        sta     polyobj_vis
        jmp     DoExplosion

        !zone   Z0082f4
.INWK_xlo =     $0c
.INWK_xhi =     $0d
.INWK_ylo =     $0f
.INWK_yhi =     $10
.INWK_zlo =     $12
.INWK_zhi =     $13
.tmp    =       $31
.polyobj_face_vis = $38
.vertex_ptr =   $5e
.x0_lo  =       $6e
.x0_hi  =       $6f
.y0_lo  =       $70
.y0_hi  =       $71
.x1_lo  =       $72
.x1_hi  =       $73
.y1_lo  =       $74
.y1_hi  =       $75
.normal_y =     $76
.ny_sign_flag = $77
.normal_z =     $78
.nz_sign_flag = $79
.x_lo   =       $98
.x_hi   =       $99
.y_lo   =       $9b
.y_hi   =       $9c
.z_lo   =       $9e
.z_hi   =       $9f
.scal_norm_z =  $ae
.s_val  =       $af
.count_v6 =     $b2
.ship_type =    $b8
.count  =       $bd        ;CNT
.xx4_visibility = $c0
.item_xcount =  $c1        ;BBC:XX20
.vertex_flags = $d0
@L8CF4  ldy     #$09       ;+$09 number of edges
        lda     (hull_ptr),y
        sta     .item_xcount
        lda     #$08
        ora     polyobj_vis
        sta     polyobj_vis
        ldy     #$00
        sty     .count_v6
        bit     polyobj_vis ;check bit 6
        bvc     @L8D47     ;bit 6 clear (laser not firing)
        lda     polyobj_vis
        and     #$bf       ;clear bit 6
        sta     polyobj_vis
        ldy     #$06       ;+$06 gun vertex
        lda     (hull_ptr),y
        tay
        ldx     BUFFER_0100,y
        stx     .x0_lo
        inx
        beq     @L8D47
        ldx     $0101,y
        stx     .x0_hi
        inx
        beq     @L8D47
        ldx     $0102,y
        stx     .y0_lo
        ldx     $0103,y
        stx     .y0_hi
        lda     #$00
        sta     .x1_lo
        sta     .x1_hi
        sta     .y1_hi
        lda     .INWK_zlo
        sta     .y1_lo
        lda     INWK+2
        bpl     @L8D3F
        dec     .x1_lo
@L8D3F  jsr     ClipLine
        bcs     @L8D47
        jsr     DrawTwoThings
; Calculate new lines.
        !zone   Z008347
.edge_ptr =     $5e
.max_lines =    $bd
@L8D47  ldy     #$03       ;+$03 offset to edges low byte
        clc
        lda     (hull_ptr),y
        adc     hull_ptr
        sta     .edge_ptr
        ldy     #$10       ;+$10 offset to edges high byte
        lda     (hull_ptr),y
        adc     hull_ptr+1
        sta     .edge_ptr+1
        ldy     #$05       ;+$05 (4 * maxlines) + 1
        lda     (hull_ptr),y
        sta     .max_lines
@CountVis
        ldy     #$00       ;count visible edges
        lda     (.edge_ptr),y ;get visibility
        cmp     $c0
        bcc     @NotVis    ;not visible
        iny
        lda     (.edge_ptr),y ;edge data byte
        sta     $31
        and     #$0f       ;face 1
        tax
        lda     $38,x      ;check visibility
        bne     @IsVis     ;visible if either face is visible
        lda     $31
        lsr
        lsr
        lsr
        lsr
        tax
        lda     $38,x
        beq     @NotVis
@IsVis  iny
        lda     (.edge_ptr),y ;get index of first vertex
        tax
        lda     BUFFER_0100,x
        sta     $6e
        lda     $0101,x
        sta     $6f
        lda     $0102,x
        sta     $70
        lda     $0103,x
        sta     $71
        iny
        lda     (.edge_ptr),y ;get index of second vertex
        tax
        lda     BUFFER_0100,x
        sta     $72
        lda     $0102,x
        sta     $74
        lda     $0103,x
        sta     $75
        lda     $0101,x
        sta     $73
        jsr     ClipLine1
        bcs     @NotVis
        jsr     DrawTwoThings
@NotVis lda     $c2
        cmp     .max_lines
        bcs     @L8DCE
        lda     .edge_ptr
        clc
        adc     #$04
        sta     .edge_ptr
        bcc     @L8DC6
        inc     .edge_ptr+1
@L8DC6  inc     $b2
        ldy     $b2
        cpy     $c1
        bcc     @CountVis
@L8DCE  jmp     DrawDot

L8DD1   lda     $6f
        bpl     @L8DEC
        sta     $af
        jsr     @L8E4B
        txa
        clc
        adc     $70
        sta     $70
        tya
        adc     $71
        sta     $71
        lda     #$00
        sta     $6e
        sta     $6f
        tax
@L8DEC  beq     @L8E07
        sta     $af
        dec     $af
        jsr     @L8E4B
        txa
        clc
        adc     $70
        sta     $70
        tya
        adc     $71
        sta     $71
        ldx     #$ff
        stx     $6e
        inx
        stx     $6f
@L8E07  lda     $71
        bpl     @L8E25
        sta     $af
        lda     $70
        sta     $ae
        jsr     @L8E7A
        txa
        clc
        adc     $6e
        sta     $6e
        tya
        adc     $6f
        sta     $6f
        lda     #$00
        sta     $70
        sta     $71
@L8E25  lda     $70
        sec
        sbc     #$88
        sta     $ae
        lda     $71
        sbc     #$00
        sta     $af
        bcc     @L8E4A
        jsr     @L8E7A
        txa
        clc
        adc     $6e
        sta     $6e
        tya
        adc     $6f
        sta     $6f
        lda     #$87
        sta     $70
        lda     #$00
        sta     $71
@L8E4A  rts

@L8E4B  lda     $6e
        sta     $ae
        jsr     @L8EB6
        pha
        ldx     $d0
        bne     @L8E82
@L8E57  lda     #$00
        tax
        tay
        lsr     $af
        ror     $ae
        asl     $ad
        bcc     @L8E6C
@L8E63  txa
        clc
        adc     $ae
        tax
        tya
        adc     $af
        tay
@L8E6C  lsr     $af
        ror     $ae
        asl     $ad
        bcs     @L8E63
        bne     @L8E6C
        pla
        bpl     @L8EA9
        rts

@L8E7A  jsr     @L8EB6
        pha
        ldx     $d0
        bne     @L8E57
@L8E82  lda     #$ff
        tay
        asl
        tax
@L8E87  asl     $ae
        rol     $af
        lda     $af
        bcs     @L8E93
        cmp     $ad
        bcc     @L8E9E
@L8E93  sbc     $ad
        sta     $af
        lda     $ae
        sbc     #$00
        sta     $ae
        sec
@L8E9E  txa
        rol
        tax
        tya
        rol
        tay
        bcs     @L8E87
        pla
        bmi     @L8EB5
@L8EA9  txa
        eor     #$ff
        adc     #$01
        tax
        tya
        eor     #$ff
        adc     #$00
        tay
@L8EB5  rts

@L8EB6  ldx     $76
        stx     $ad
        lda     $af
        bpl     @L8ECF
        lda     #$00
        sec
        sbc     $ae
        sta     $ae
        lda     $af
        pha
        eor     #$ff
        adc     #$00
        sta     $af
        pla
@L8ECF  eor     $77
        rts

; 
; Clips a line to the viewport.
; 
; Looks like it's performing midpoint subdivision.
; 
; Viewport area appears to be 256x135.
; 
; On entry:
;   $6e/6f: x0
;   $70/71: y0
;   $72/73: x1
;   $74/75: y1
; 
; On exit:
;   $6e: clipped x0
;   $6f: clipped y0
;   $70: clipped x1
;   $71: clipped y1
; 
        !zone   Z0084d2
.x0_lo  =       $6e
.x0_hi  =       $6f
.y0_lo  =       $70
.y0_hi  =       $71
.x1_lo  =       $72
.x1_hi  =       $73
.y1_lo  =       $74
.y1_hi  =       $75
.yclip  =       $b5
ClipLine
        lda     #$00
        sta     lcoord_swap_flag
        lda     .x1_hi
ClipLine1
        ldx     #135       ;viewport height
        ora     .y1_hi
        bne     @SkipYcReset
        cpx     .y1_lo
        bcc     @SkipYcReset
        ldx     #$00
@SkipYcReset
        stx     .yclip
        lda     .x0_hi
        ora     .y0_hi
        bne     @L8F09
        lda     #135       ;viewport height
        cmp     .y0_lo
        bcc     @L8F09
        lda     .yclip
        bne     @L8F07
@L8EF7  lda     .y0_lo     ;copy *_lo to outputs
        sta     .x0_hi
        lda     .x1_lo
        sta     .y0_lo
        lda     .y1_lo
        sta     .y0_hi
        clc                ;valid to plot
        rts

@NotVisible
        sec                ;clipped line not visible
        rts

@L8F07  lsr     .yclip     ;yclip = ymid
@L8F09  lda     .yclip
        bpl     @L8F3C
        lda     .x0_hi
        and     .x1_hi
        bmi     @NotVisible
        lda     .y0_hi
        and     .y1_hi
        bmi     @NotVisible
        ldx     .x0_hi
        dex
        txa
        ldx     .x1_hi
        dex
        stx     $76
        ora     $76
        bpl     @NotVisible
        lda     .y0_lo
        cmp     #$88
        lda     .y0_hi
        sbc     #$00
        sta     $76
        lda     .y1_lo
        cmp     #$88
        lda     .y1_hi
        sbc     #$00
        ora     $76
        bpl     @NotVisible
@L8F3C  tya
        pha
        lda     .x1_lo
        sec
        sbc     .x0_lo
        sta     $76
        lda     .x1_hi
        sbc     .x0_hi
        sta     $77
        lda     .y1_lo
        sec
        sbc     .y0_lo
        sta     $78
        lda     .y1_hi
        sbc     .y0_hi
        sta     $79
        eor     $77
        sta     $af
        lda     $79
        bpl     @L8F6D
        lda     #$00
        sec
        sbc     $78
        sta     $78
        lda     #$00
        sbc     $79
        sta     $79
@L8F6D  lda     $77
        bpl     @L8F7C
        sec
        lda     #$00
        sbc     $76
        sta     $76
        lda     #$00
        sbc     $77
@L8F7C  tax
        bne     @L8F83
        ldx     $79
        beq     @L8F8D
@L8F83  lsr
        ror     $76
        lsr     $79
        ror     $78
        jmp     @L8F7C

@L8F8D  stx     $d0
        lda     $76
        cmp     $78
        bcc     @L8F9F
        sta     $ad
        lda     $78
        jsr     BFRDIV
        jmp     @L8FAA

@L8F9F  lda     $78
        sta     $ad
        lda     $76
        jsr     BFRDIV
        dec     $d0
@L8FAA  lda     $ae
        sta     $76
        lda     $af
        sta     $77
        lda     .yclip
        beq     @L8FB8
        bpl     @L8FCB
@L8FB8  jsr     L8DD1
        lda     .yclip
        bpl     @L8FF1
        lda     .x0_hi
        ora     .y0_hi
        bne     @L8FF6
        lda     .y0_lo
        cmp     #$88
        bcs     @L8FF6
@L8FCB  ldx     .x0_lo
        lda     .x1_lo
        sta     .x0_lo
        stx     .x1_lo
        lda     .x1_hi
        ldx     .x0_hi
        stx     .x1_hi
        sta     .x0_hi
        ldx     .y0_lo
        lda     .y1_lo
        sta     .y0_lo
        stx     .y1_lo
        lda     .y1_hi
        ldx     .y0_hi
        stx     .y1_hi
        sta     .y0_hi
        jsr     L8DD1
        dec     lcoord_swap_flag
@L8FF1  pla
        tay
        jmp     @L8EF7

@L8FF6  pla
        tay
        sec
        rts

        !zone   Z0085fa
.screen_x0 =    $6e
.screen_y0 =    $6f
.screen_x1 =    $70
.screen_y1 =    $71
DrawDot ldy     $c2
@Loop   cpy     $c3
        bcs     @Done
        lda     (tmp_ptr2),y
        iny
        sta     .screen_x0
        lda     (tmp_ptr2),y
        iny
        sta     .screen_y0
        lda     (tmp_ptr2),y
        iny
        sta     .screen_x1
        lda     (tmp_ptr2),y
        iny
        sta     .screen_y1
        jsr     DrawLine
        jmp     @Loop

@Done   lda     $c2
        ldy     #$00
        sta     (tmp_ptr2),y
Return3 rts

DrawTwoThings
        ldy     $c2
        cpy     $c3
        php
        ldx     #$03
@CopyLoop
        lda     .screen_x0,x
        sta     $74,x
        dex
        bpl     @CopyLoop
        jsr     DrawLine
        lda     (tmp_ptr2),y
        sta     .screen_x0
        lda     $74
        sta     (tmp_ptr2),y
        iny
        lda     (tmp_ptr2),y
        sta     .screen_y0
        lda     $75
        sta     (tmp_ptr2),y
        iny
        lda     (tmp_ptr2),y
        sta     .screen_x1
        lda     $76
        sta     (tmp_ptr2),y
        iny
        lda     (tmp_ptr2),y
        sta     .screen_y1
        lda     $77
        sta     (tmp_ptr2),y
        iny
        sty     $c2
        plp
        bcs     Return3
        jmp     DrawLine

MVEIT   lda     polyobj_vis
        and     #$a0
        bne     @L9089
        lda     $b6
        eor     $b0
        and     #$0f
        bne     @L906F
        jsr     L85FB
@L906F  ldx     $b8
        bpl     @L9076
        jmp     L92FB

@L9076  lda     polyobj_attack
        bpl     @L9089
        cpx     #$01
        beq     @L9086
        lda     $b6
        eor     $b0
        and     #$07
        bne     @L9089
@L9086  jsr     TACTICS
@L9089  jsr     SCAN
        lda     polyobj_vertex_lo
        asl
        asl
        sta     $ad
        lda     $16
        and     #$7f
        jsr     FMLTU
        sta     $ae
        lda     $16
        ldx     #$00
        jsr     L9208
        lda     $18
        and     #$7f
        jsr     FMLTU
        sta     $ae
        lda     $18
        ldx     #$03
        jsr     L9208
        lda     polyobj_mox2_hi
        and     #$7f
        jsr     FMLTU
        sta     $ae
        lda     polyobj_mox2_hi
        ldx     #$06
        jsr     L9208
        lda     polyobj_vertex_lo
        clc
        adc     $28
        bpl     @L90CB
        lda     #$00
@L90CB  ldy     #$0f       ;max speed
        cmp     (hull_ptr),y ;get from hull definition
        bcc     @NotMax
        lda     (hull_ptr),y ;cap it at max
@NotMax sta     polyobj_vertex_lo
        lda     #$00
        sta     $28
        ldx     $6b
        lda     polyobj_xpos_lo
        eor     #$ff
        sta     $31
        lda     INWK+1
        jsr     MLTU2
        sta     $33
        lda     $6d
        eor     INWK+2
        ldx     #$03
        jsr     L92C6
        sta     $c9
        lda     $32
        sta     $c7
        eor     #$ff
        sta     $31
        lda     $33
        sta     $c8
        ldx     $67
        jsr     MLTU2
        sta     $33
        lda     $c9
        eor     $a7
        ldx     #$06
        jsr     L92C6
        sta     polyobj_zpos_hi
        lda     $32
        sta     polyobj_zpos_lo
        eor     #$ff
        sta     $31
        lda     $33
        sta     polyobj_zpos_mi
        jsr     MLTU2_2
        sta     $33
        lda     $c9
        sta     INWK+5
        eor     $a7
        eor     polyobj_zpos_hi
        bpl     @L913B
        lda     $32
        adc     $c7
        sta     polyobj_ypos_lo
        lda     $33
        adc     $c8
        sta     INWK+4
        jmp     @L915B

@L913B  lda     $c7
        sbc     $32
        sta     polyobj_ypos_lo
        lda     $c8
        sbc     $33
        sta     INWK+4
        bcs     @L915B
        lda     #$01
        sbc     polyobj_ypos_lo
        sta     polyobj_ypos_lo
        lda     #$00
        sbc     INWK+4
        sta     INWK+4
        lda     INWK+5
        eor     #$80
        sta     INWK+5
@L915B  ldx     $6b
        lda     polyobj_ypos_lo
        eor     #$ff
        sta     $31
        lda     INWK+4
        jsr     MLTU2
        sta     $33
        lda     $6c
        eor     INWK+5
        ldx     #$00
        jsr     L92C6
        sta     INWK+2
        lda     $33
        sta     INWK+1
        lda     $32
        sta     polyobj_xpos_lo
L917D   lda     player_speed
        sta     $ae
        lda     #$80
        ldx     #$06
        jsr     L920A
        lda     $b8
        and     #$81
        cmp     #$81
        bne     @L9191
        rts

@L9191  ldy     #$09
        jsr     L925F
        ldy     #$0f
        jsr     L925F
        ldy     #$15
        jsr     L925F
        lda     polyobj_pitch
        and     #$80
        sta     $c5
        lda     polyobj_pitch
        and     #$7f
        beq     @L91C9
        cmp     #$7f
        sbc     #$00
        ora     $c5
        sta     polyobj_pitch
        ldx     #$0f
        ldy     #$09
        jsr     L53D4
        ldx     #$11
        ldy     #$0b
        jsr     L53D4
        ldx     #$13
        ldy     #$0d
        jsr     L53D4
@L91C9  lda     polyobj_roll
        and     #$80
        sta     $c5
        lda     polyobj_roll
        and     #$7f
        beq     @L91F2
        cmp     #$7f
        sbc     #$00
        ora     $c5
        sta     polyobj_roll
        ldx     #$0f
        ldy     #$15
        jsr     L53D4
        ldx     #$11
        ldy     #$17
        jsr     L53D4
        ldx     #$13
        ldy     #$19
        jsr     L53D4
@L91F2  lda     polyobj_vis
        and     #$a0
        bne     @L9201
        lda     polyobj_vis
        ora     #$10
        sta     polyobj_vis
        jmp     SCAN

@L9201  lda     polyobj_vis
        and     #$ef
        sta     polyobj_vis
        rts

L9208   and     #$80
L920A   asl
        sta     $af
        lda     #$00
        ror
        sta     $d0
        lsr     $af
        eor     INWK+2,x
        bmi     @L922D
        lda     $ae
        adc     polyobj_xpos_lo,x
        sta     polyobj_xpos_lo,x
        lda     $af
        adc     INWK+1,x
        sta     INWK+1,x
        lda     INWK+2,x
        adc     #$00
        ora     $d0
        sta     INWK+2,x
        rts

@L922D  lda     polyobj_xpos_lo,x
        sec
        sbc     $ae
        sta     polyobj_xpos_lo,x
        lda     INWK+1,x
        sbc     $af
        sta     INWK+1,x
        lda     INWK+2,x
        and     #$7f
        sbc     #$00
        ora     #$80
        eor     $d0
        sta     INWK+2,x
        bcs     @L925E
        lda     #$01
        sbc     polyobj_xpos_lo,x
        sta     polyobj_xpos_lo,x
        lda     #$00
        sbc     INWK+1,x
        sta     INWK+1,x
        lda     #$00
        sbc     INWK+2,x
        and     #$7f
        ora     $d0
        sta     INWK+2,x
@L925E  rts

L925F   lda     $b9
        sta     $ad
        ldx     INWK+2,y
        stx     $ae
        ldx     polyobj_ypos_lo,y
        stx     $af
        ldx     polyobj_xpos_lo,y
        stx     $31
        lda     INWK+1,y
        eor     #$80
        jsr     MAD
        sta     polyobj_ypos_lo,y
        stx     INWK+2,y
        stx     $31
        ldx     polyobj_xpos_lo,y
        stx     $ae
        ldx     INWK+1,y
        stx     $af
        lda     polyobj_ypos_lo,y
        jsr     MAD
        sta     INWK+1,y
        stx     polyobj_xpos_lo,y
        stx     $31
        lda     $66
        sta     $ad
        ldx     INWK+2,y
        stx     $ae
        ldx     polyobj_ypos_lo,y
        stx     $af
        ldx     INWK+4,y
        stx     $31
        lda     INWK+5,y
        eor     #$80
        jsr     MAD
        sta     polyobj_ypos_lo,y
        stx     INWK+2,y
        stx     $31
        ldx     INWK+4,y
        stx     $ae
        ldx     INWK+5,y
        stx     $af
        lda     polyobj_ypos_lo,y
        jsr     MAD
        sta     INWK+5,y
        stx     INWK+4,y
        rts

L92C6   tay
        eor     INWK+2,x
        bmi     @L92DA
        lda     $32
        clc
        adc     polyobj_xpos_lo,x
        sta     $32
        lda     $33
        adc     INWK+1,x
        sta     $33
        tya
        rts

@L92DA  lda     polyobj_xpos_lo,x
        sec
        sbc     $32
        sta     $32
        lda     INWK+1,x
        sbc     $33
        sta     $33
        bcc     @L92ED
        tya
        eor     #$80
        rts

@L92ED  lda     #$01
        sbc     $32
        sta     $32
        lda     #$00
        sbc     $33
        sta     $33
        tya
        rts

L92FB   lda     $b9
        eor     #$80
        sta     $ad
        lda     polyobj_xpos_lo
        sta     $31
        lda     INWK+1
        sta     $32
        lda     INWK+2
        jsr     L5EA2
        ldx     #$03
        jsr     L5378
        lda     $7b
        sta     $c7
        sta     $31
        lda     $7c
        sta     $c8
        sta     $32
        lda     $66
        sta     $ad
        lda     $7d
        sta     $c9
        jsr     L5EA2
        ldx     #$06
        jsr     L5378
        lda     $7b
        sta     $31
        sta     polyobj_zpos_lo
        lda     $7c
        sta     $32
        sta     polyobj_zpos_mi
        lda     $7d
        sta     polyobj_zpos_hi
        eor     #$80
        jsr     L5EA2
        lda     $7d
        and     #$80
        sta     $d0
        eor     $c9
        bmi     @L9366
        lda     $7a
        clc
        adc     $c6
        lda     $7b
        adc     $c7
        sta     polyobj_ypos_lo
        lda     $7c
        adc     $c8
        sta     INWK+4
        lda     $7d
        adc     $c9
        jmp     @L9399

@L9366  lda     $7a
        sec
        sbc     $c6
        lda     $7b
        sbc     $c7
        sta     polyobj_ypos_lo
        lda     $7c
        sbc     $c8
        sta     INWK+4
        lda     $c9
        and     #$7f
        sta     $31
        lda     $7d
        and     #$7f
        sbc     $31
        sta     $31
        bcs     @L9399
        lda     #$01
        sbc     polyobj_ypos_lo
        sta     polyobj_ypos_lo
        lda     #$00
        sbc     INWK+4
        sta     INWK+4
        lda     #$00
        sbc     $31
        ora     #$80
@L9399  eor     $d0
        sta     INWK+5
        lda     $b9
        sta     $ad
        lda     polyobj_ypos_lo
        sta     $31
        lda     INWK+4
        sta     $32
        lda     INWK+5
        jsr     L5EA2
        ldx     #$00
        jsr     L5378
        lda     $7b
        sta     polyobj_xpos_lo
        lda     $7c
        sta     INWK+1
        lda     $7d
        sta     INWK+2
        jmp     L917D

L93C2   ldx     PLAYER_STATE+49
        beq     @L93FA
        dex
        bne     @L93FB
        lda     INWK+2
        eor     #$80
        sta     INWK+2
        lda     polyobj_zpos_hi
        eor     #$80
        sta     polyobj_zpos_hi
        lda     $16
        eor     #$80
        sta     $16
        lda     polyobj_mox2_hi
        eor     #$80
        sta     polyobj_mox2_hi
        lda     $1c
        eor     #$80
        sta     $1c
        lda     $20
        eor     #$80
        sta     $20
        lda     $22
        eor     #$80
        sta     $22
        lda     $26
        eor     #$80
        sta     $26
@L93FA  rts

@L93FB  lda     #$00
        cpx     #$02
        ror
        sta     $c5
        eor     #$80
        sta     $c4
        lda     polyobj_xpos_lo
        ldx     polyobj_zpos_lo
        sta     polyobj_zpos_lo
        stx     polyobj_xpos_lo
        lda     INWK+1
        ldx     polyobj_zpos_mi
        sta     polyobj_zpos_mi
        stx     INWK+1
        lda     INWK+2
        eor     $c4
        tax
        lda     polyobj_zpos_hi
        eor     $c5
        sta     INWK+2
        stx     polyobj_zpos_hi
        ldy     #$09
        jsr     @L942F
        ldy     #$0f
        jsr     @L942F
        ldy     #$15
@L942F  lda     polyobj_xpos_lo,y
        ldx     INWK+4,y
        sta     INWK+4,y
        stx     polyobj_xpos_lo,y
        lda     INWK+1,y
        eor     $c4
        tax
        lda     INWK+5,y
        eor     $c5
        sta     INWK+1,y
        stx     INWK+5,y
Return4 rts

L944A   stx     PLAYER_STATE+49
        jsr     PrintFlightHud
        jsr     L947D
        lda     have_energy_bomb
        bpl     @L945B
        jsr     DrawBombAnim
@L945B  jmp     L73CD

; 
; Set the view direction (forward/left/right/back).
; 
; On entry:
;   X-reg: direction (0=front, 1=rear, 2=left, 3=right)
; 
SetViewDirection
        lda     #$00
        ldy     displayed_screen
        bne     L944A
        cpx     PLAYER_STATE+49
        beq     Return4    ;view unchanged
        stx     PLAYER_STATE+49
        jsr     PrintFlightHud
        jsr     L5026
        lda     have_energy_bomb
        bpl     @L947A
        jsr     DrawBombAnim
@L947A  jsr     L73F3
L947D   ldy     PLAYER_STATE+49
        lda     $029f,y
        beq     Return4
        ldy     #$00
        cmp     #$0f
        beq     @L9496
        iny
        cmp     #$8f
        beq     @L9496
        iny
        cmp     #$97
        beq     @L9496
        iny
@L9496  lda     @L94B1,y
        sta     $35
        lda     #$80
        sta     $a1
        lda     #$2c
        sta     $a2
        lda     #$14
        sta     $a3
        jsr     L6642
        lda     #$0a
        sta     $a3
        jmp     L6642

@L94B1  !byte   $10
        !byte   $14
        !byte   $0c
        !byte   $0c
        !byte   $04
        !byte   $14
        !byte   $08
        !byte   $0c

PrintFlightHud
        sta     displayed_screen
L94BB   jsr     SetUcaseMask
        lda     #$00
        sta     $91
        lda     #$80
        sta     text_mod_flags
        sta     txt_lcase_flag
        lda     #$01
        sta     text_hposn
        sta     text_vposn
        jsr     LA197
        lda     display_mode_flag
        bmi     @L94D9
        jsr     L7428
@L94D9  lda     #$00
        sta     PLAYER_STATE+47
        sta     PLAYER_STATE+54
        sta     $0278
        ldx     $69
        beq     @L94EB
        jsr     L6C03
@L94EB  lda     #$01
        sta     text_vposn
        lda     displayed_screen
        bne     @L9507
        lda     #11
        sta     text_hposn
        lda     PLAYER_STATE+49
        ora     #$60       ;"Front"/"Rear"/"Left"/"Right"
        jsr     PrintFlightToken
        jsr     PrintSpace
        lda     #$af       ;"View"
        jsr     PrintFlightToken
@L9507  ldx     #$01
        stx     text_hposn
        stx     text_vposn
        dex
        stx     text_mod_flags ;flags=0
        rts

L9511   rts

L9512   lda     #$00
        sta     ecm_active_flag
        sta     player_ecm_active
        jmp     LA013

; BBC .SFRMIS
; "Spawn missile with ai=#$FE max but no ecm"
LaunchMissile
        ldx     #1         ;missile
        jsr     LaunchObject
        bcc     L9511
        lda     #$78       ;"Incoming Missile"
        jsr     PrintMessageBriefly
        ldy     #$32
        jmp     MakeNoise1

CountKill
        lda     kill_score_rem
        clc
        adc     kill_score_lo-1,x
        sta     kill_score_rem
        lda     kill_score
        adc     kill_score_hi-1,x
        sta     kill_score
        bcc     @NoInc
        inc     kill_score+1
        lda     #$65       ;"Right On Commander!"
        jsr     PrintMessageBriefly ;(prints every 256 kill-scores)
@NoInc  ldy     #$37
        bne     L9571

L954E   ldy     #$0f
        bne     L9571

Noise1  ldy     #$63
        ldx     #$ff
        bne     MakeNoise31

MakeNoise1
        bit     sound_disab_flag
        bmi     Return5
@L955D  lda     SPKR       ;click
        jsr     GetRandom
@L9563  dex
        nop
        nop
        bne     @L9563
        dey
        bne     @L955D
        lda     SPKR
        rts

MakeNoise2
        ldy     #$28
L9571   bit     sound_disab_flag
        bmi     Return5
        ldx     #$32
        stx     $08
@L957A  lda     SPKR
        inc     $08
        ldx     $08
@L9581  dex
        nop
        nop
        bne     @L9581
        jsr     GetRandom
@L9589  dex
        nop
        bne     @L9589
        dey
        bne     @L957A
        lda     SPKR
        rts

MakeNoise3
        ldy     #$1e
        ldx     #$6e
MakeNoise31
        bit     sound_disab_flag
        bmi     Return5
        stx     $08
@L959F  lda     SPKR
        ldx     $08
@L95A4  dex
        bne     @L95A4
        dey
        bne     @L959F
        lda     SPKR
Return5 rts

MakeNoise4
        bit     sound_disab_flag
        bmi     Return5
        stx     $08
@L95B5  lda     SPKR
        dec     $08
        ldx     $08
@L95BC  dex
        nop
        bne     @L95BC
        dey
        bne     @L95B5
        lda     SPKR
        rts

MakeNoise5
        ldy     #$0b
        ldx     #$96
        bit     sound_disab_flag
        bmi     Return5
        stx     $08
@L95D2  lda     SPKR
        inc     $08
        inc     $08
        ldx     $08
@L95DB  dex
        bne     @L95DB
        dey
        bne     @L95D2
        lda     SPKR
        rts

        !byte   $a0
        !byte   $0b
        !byte   $a2
        !byte   $82

MakeNoise6
        bit     sound_disab_flag
        bmi     Return5
        ldy     #$19
@L95F0  lda     SPKR
        jsr     GetRandom
        and     #$1f
        ora     #$e0
        tax
@L95FB  dex
        nop
        bne     @L95FB
        dey
        bne     @L95F0
        lda     SPKR
        rts

MakeNoise7
        bit     sound_disab_flag
        bmi     @L960E
        lda     SPKR
@L960E  rts

; 
; Initialize some basic things: show the hi-res screen, zero out variable
; storage, etc.
; 
        !zone   Z008c0f
.ptr    =       $0a
InitSystem
        jsr     ShowHiRes
        lda     #$08       ;set ptr to $800
        sta     .ptr+1
        ldx     #$02       ;erase two pages ($800-9FF)
        lda     #$00
        sta     .ptr
        tay                ;A/Y to zero
@Loop   sta     (.ptr),y
        iny
        bne     @Loop
        inc     .ptr+1
        dex
        bne     @Loop
@L9627  sta     $0200,y    ;clear $200-2ff
        dey
        bne     @L9627
        lda     #$41       ;set NMI vector for some reason
        sta     NMIVEC+1
        lda     #$96
        sta     NMIVEC+2
        lda     #$93       ;line ~18
        sta     text_vposn
        lda     #$a0
        sta     text_mod_flags
        sei                ;disable interrupts
        rts

        !byte   $58
        !byte   $40
disk_filename
        !text   "COMMANDER                     "

DiskLoadGame
        tsx
        stx     rwts_saved_stack
        jsr     DiskFindFile
        lda     #$05
        bcs     Return6
        jsr     DiskLoadTSList
        jsr     DiskReadSector
        ldy     #$00       ;copy data to scrambled-save area
@Loop   lda     data_buffer+4,y ;start at offset +4 to skip 'B' header
        sta     scram_save_data,y
        iny
        cpy     #$6e       ;length of saved-game data
        bne     @Loop
        clc
Return6 rts

DiskSaveGame
        jsr     ScrambleSaveData
        tsx
        stx     rwts_saved_stack
        jsr     DiskFindFile
        bcc     @FoundFile
; File doesn't exist, create it.
        jsr     L97C4
        lda     #$02
        bcs     Return6
        jsr     DiskFindEmpty ;find an empty slot (returned in Y-reg)
        lda     #$03
        bcs     Return6    ;return with err 3 (cat full) if we failed
        lda     rwts_ts_track ;set track/sector for file T/S list
        sta     data_buffer,y
        lda     rwts_ts_sector
        sta     data_buffer+1,y
        lda     #$04       ;type 'B'
        sta     data_buffer+2,y
        lda     #$02       ;length in sectors = $0002
        sta     data_buffer+33,y
        lda     #$00
        sta     data_buffer+34,y
        tax                ;X-reg=0
@Loop   lda     disk_filename,x ;copy filename
        ora     #$80       ;set high ASCII
        sta     data_buffer+3,y
        iny
        inx
        cpx     #30
        bne     @Loop
        jsr     DiskWriteSector ;write the catalog sector
        jsr     L97C4
        jsr     DiskWriteSector
        lda     #$00
        tay
@L96D1  sta     data_buffer,y
        iny
        bne     @L96D1
        lda     rwts_alloc_track
        sta     data_buffer+12
        lda     rwts_alloc_sector
        sta     data_buffer+13
        lda     rwts_ts_track
        sta     rwts_track
        lda     rwts_ts_sector
        sta     rwts_sector
        jsr     DiskWriteSector
        lda     rwts_alloc_track
        sta     rwts_track
        lda     rwts_alloc_sector
        sta     rwts_sector
        bpl     @L9703
@FoundFile
        jsr     DiskLoadTSList
@L9703  ldy     #$00
@L9705  lda     scram_save_data,y
        sta     data_buffer+4,y
        iny
        cpy     #$6e
        bne     @L9705
        jmp     DiskWriteSector

; 
; Finds an entry with a matching filename in the disk catalog.
; 
        !zone   Z008d13
.max_tries =    $6e
.chksum =       $6f
.max_retry =    $70
DiskFindFile
        clc
        bcc     DiskFindCommon

; 
; Finds the first empty or deleted slot in the catalog.
; 
DiskFindEmpty
        sec
DiskFindCommon
        ror     rwts_find_slot_flag ;set high bit to carry flag
        jsr     DiskReadVtoc ;load the VTOC
@GetCatSect
        lda     data_buffer+1 ;T/S of first catalog sector
        sta     rwts_track
        lda     data_buffer+2
        sta     rwts_sector
        jsr     DiskReadSector ;read sector
        ldy     #11        ;first cat entry at +11
@CheckEntry
        lda     data_buffer,y ;+0 is unused/deleted flag
        bit     rwts_find_slot_flag ;are we looking for an empty slot?
        bpl     @FindFile  ;no, branch
        tax                ;see if entry is unused
        beq     @Done      ;yes, bail out
        cmp     #$ff       ;deleted file?
        beq     @Done      ;yes, bail out
        bne     @TryNext

@FindFile
        tax                ;empty slot?
        beq     @Fail      ;yes, assume end of catalog
        cmp     #$ff       ;deleted file?
        beq     @TryNext   ;yes, try next slot
        tya
        pha                ;save offset
        ldx     #$00
@StrCmp lda     data_buffer+3,y ;filename starts at +3
        and     #$7f       ;normalize high bit
        cmp     disk_filename,x ;compare to desired filename
        bne     @NoMatch
        iny
        inx
        cpx     #30        ;filenames are 30 chars long
        bne     @StrCmp    ;not done yet
        pla                ;success; restore slot offset
        tay
@Done   clc
        rts

@NoMatch
        pla                ;restore offset
        tay
@TryNext
        tya
        clc
        adc     #35        ;advance to next entry (35 bytes each)
        tay
        bne     @CheckEntry
        lda     data_buffer+1 ;is there another catalog sector?
        bne     @GetCatSect ;yes, try that one
@Fail   sec
        rts

        !zone   Z008d6e
.sector =       $6e
.chksum =       $6f
.max_retry =    $70
DiskAllocateSector
        lda     #$00
        sta     .sector
        beq     @L9777     ;(always)

@L9774  lda     data_buffer+49 ;+$31 direction of allocation
@L9777  clc
        adc     data_buffer+48 ;+$30 last track where sectors were allocated
        beq     @L9786
        cmp     data_buffer+52 ;+$34 number of tracks per disk
        bcc     @L9794
        lda     #$ff
        bne     @L978E

@L9786  lda     .sector
        bne     @L97C2
        lda     #$01
        sta     .sector
@L978E  sta     data_buffer+49
        clc
        adc     #$11
@L9794  sta     data_buffer+48
        asl
        asl
        tay
        ldx     #$10
        lda     data_buffer+56,y ;+$38 volume bitmap
        bne     @L97A9
        iny
        ldx     #$08
        lda     data_buffer+56,y
        beq     @L9774
@L97A9  stx     .sector
        ldx     #$00
@L97AD  inx
        dec     .sector
        rol
        bcc     @L97AD
        clc
@L97B4  ror
        dex
        bne     @L97B4
        sta     data_buffer+56,y
        ldx     data_buffer+48 ;track
        ldy     .sector    ;sector
        clc
        rts

@L97C2  sec
        rts

L97C4   jsr     DiskReadVtoc
        jsr     DiskAllocateSector
        bcs     @L97DB
        stx     rwts_ts_track
        sty     rwts_ts_sector
        jsr     DiskAllocateSector
        stx     rwts_alloc_track ;T/S list track/sector
        sty     rwts_alloc_sector
@L97DB  rts

; 
; Load a file's T/S list into memory.
; 
; On entry:
;   data buffer holds the catalog sector
;   Y-reg: offset to entry in catalog
; 
; On exit:
;   rwts_track: first entry from T/S list
;   rwts_sector: first entry from T/S list
;   Y-reg: $0C (offset of first entry)
; 
DiskLoadTSList
        lda     data_buffer,y
        sta     rwts_track
        lda     data_buffer+1,y
        sta     rwts_sector
        jsr     DiskReadSector ;read T/S list
        ldy     #$0c       ;offset of first entry in list
        lda     data_buffer,y
        sta     rwts_track
        lda     data_buffer+1,y
        sta     rwts_sector
        rts

; 
; Read the disk VTOC.
; 
DiskReadVtoc
        lda     #17        ;disk VTOC (T17 S0)
        sta     rwts_track
        lda     #0
        sta     rwts_sector ;fall through to read routine
; 
; Reads the requested track/sector.
; 
; Assumes slot 6 drive 1.
; 
; On entry:
;   rwts_track: track to read
;   rwts_sector: sector to read
; 
DiskReadSector
        clc                ;C=0 -> read
        bcc     RWCommon

DiskWriteSector
        sec                ;C=1 -> write
RWCommon
        php                ;save flags for later
        lda     #$60       ;assume slot 6
        sta     rwts_slot
        lda     #$02
        sta     rwts_retry_1
        lda     #$04
        sta     rwts_retry_2
        lda     #$d8
        sta     rwts_delay_ctr+1
        ldx     rwts_slot
        lda     IWM_Q7_OFF,x ;configure read mode
        lda     IWM_Q6_OFF,x
        ldy     #$08       ;repeat 8x
@ChkChange
        lda     IWM_Q6_OFF,x ;get pending byte
        pha
        pla
        pha
        pla
        cmp     BUFFER_0100 ;stall for 18 cycles
        cmp     IWM_Q6_OFF,x ;has the data changed?
        bne     @DidChange ;yes, good to go
        dey
        bne     @ChkChange ;try again
@DidChange
        php                ;preserve Z flag
        lda     IWM_MOTOR_ON,x ;start the disk spinning
        lda     IWM_DRIVE_1,x ;select drive 1
        plp                ;restore Z flag
        php
        bne     @DidChange2
        ldy     #$07       ;call delay function 7x
@DelayLoop
        jsr     DiskDelay  ;first call delays by whatever is in A-reg
        dey                ;subsequent calls delay by A=0 (256 iterations)
        bne     @DelayLoop
        ldx     rwts_slot  ;reload X-reg (trashed by delay func)
@DidChange2
        lda     rwts_track
        jsr     DiskSeekToTrack ;seek to target track
        plp                ;restore Z flag
        bne     @DidChange3
        ldy     rwts_delay_ctr+1
        bpl     @DidChange3
@Loop1  ldy     #$12       ;let's wait some more
@Loop2  dey
        bne     @Loop2
        inc     rwts_delay_ctr
        bne     @Loop1
        inc     rwts_delay_ctr+1
        bne     @Loop1
@DidChange3
        plp                ;restore initial flags
        php
        bcc     @ReadHeader
        jsr     DiskEncode62 ;for writing, perform 6&2 encoding
@ReadHeader
        ldy     #$30
        sty     .max_retry
@ReadHdrLoop
        ldx     rwts_slot
        jsr     DiskReadNextAddr ;find the next address field
        bcc     @HdrOk
@TryNextSector
        dec     .max_retry
        bpl     @ReadHdrLoop
@DecRetry1
        dec     rwts_retry_1
        beq     @Fail
; Something went wrong.  Try to reset.
        lda     #$04
        sta     rwts_retry_2
        lda     #$60
        sta     rwts_current_track
        lda     #$00       ;seek to track 0
        jsr     DiskSeekToTrack
@SeekToTrack
        lda     rwts_track ;seek to desired track
        jsr     DiskSeekToTrack
        jmp     @ReadHeader ;try again

@HdrOk  ldy     rwts_addr_track ;get the track we read from addr header
        cpy     rwts_track ;does it match where we think we are?
        beq     @GoodTrack ;yes, branch
        dec     rwts_retry_2
        bne     @SeekToTrack
        beq     @DecRetry1 ;(always)

        !hex    a9011034a904

@ReturnErr
        ldx     rwts_saved_stack
        txs
        ldx     rwts_slot
        ldy     IWM_MOTOR_OFF,x ;turn drive off
        sec                ;indicate error (code in A-reg)
        rts

@GoodTrack
        ldy     rwts_sector ;get desired sector number
        lda     rwts_sect_skew,y ;convert to physical
        cmp     rwts_addr_sect ;is this what we found?
        bne     @TryNextSector ;no, keep looking
        plp                ;check status flags
        bcs     @DoWrite   ;C=1, writing
        jsr     DiskReadSectData ;C=0, reading
        php                ;push flags -- WARNING a failed read will switch us
        bcs     @TryNextSector ; to write mode!
        plp
        jsr     DiskDecode62
        jmp     @Done

@DoWrite
        jsr     DiskWriteSectData
        bcc     @Done
        lda     #$01
        bpl     @ReturnErr ;(always)

@Fail   lda     #$04
        ldx     rwts_saved_stack
        txs
        sec
        bcs     @MotorOff

@Done   lda     #$00
        clc
@MotorOff
        ldx     rwts_slot
        ldy     IWM_MOTOR_OFF,x
        rts

; 
; Reads the sector data header and contents.
; 
; This appears to be identical to the DOS 3.3 READ routine ($B8DC).
; 
; On entry:
;   X-reg: slot * 16
; 
; On exit:
;   C=0 on success, C=1 on failure
; 
        !zone   Z008ef9
.bits   =       $6e
.chksum =       $6f
.max_retry =    $70
DiskReadSectData
        ldy     #$20
@L98FB  dey
        beq     @Fail
@RdLoop lda     IWM_Q6_OFF,x ;look for data prologue (D5 AA AD)
        bpl     @RdLoop
@L9903  eor     #$d5
        bne     @L98FB
        nop
@RdLoop1
        lda     IWM_Q6_OFF,x
        bpl     @RdLoop1
        cmp     #$aa
        bne     @L9903
        ldy     #86        ;want 86 bytes of 2/2/2 data
@RdLoop2
        lda     IWM_Q6_OFF,x
        bpl     @RdLoop2
        cmp     #$ad
        bne     @L9903
; Got the header, read the sector data.
        lda     #$00
@ReadTwosLoop
        dey
        sty     .bits
@RdLoop3
        ldy     IWM_Q6_OFF,x
        bpl     @RdLoop3
        eor     TrackStep+2,y
        ldy     .bits
        sta     L0A00,y
        bne     @ReadTwosLoop
@ReadSixesLoop
        sty     .bits      ;want 256 bytes of 6-bit data
@RdLoop4
        ldy     IWM_Q6_OFF,x
        bpl     @RdLoop4
        eor     rwts_decode62-150,y
        ldy     .bits
        sta     $0900,y
        iny
        bne     @ReadSixesLoop
@RdLoop5
        ldy     IWM_Q6_OFF,x
        bpl     @RdLoop5
        cmp     rwts_decode62-150,y
        bne     @Fail
@RdLoop6
        lda     IWM_Q6_OFF,x ;look for data epilogue (DE AA)
        bpl     @RdLoop6
        cmp     #$de
        bne     @Fail
        nop
@RdLoop7
        lda     IWM_Q6_OFF,x
        bpl     @RdLoop7
        cmp     #$aa
        beq     @L9961
@Fail   sec
        rts

@L9961  clc
        rts

; 
; Writes the sector data header and contents.  This appears to be identical to
; the DOS 3.3 WRITE routine ($B82A).
; 
; IMPORTANT: most of this code is timing-critical and must fit on a single page,
; because branching across a page boundary costs an extra cycle.
; 
; On entry:
;   X-reg: slot * 16
; 
        !zone   Z008f63
.last_val =     $6e
.slot   =       $6f
DiskWriteSectData
        sec                ;set in case of write-protect failure
        stx     .slot
        lda     IWM_Q6_ON,x ;check write protect
        lda     IWM_Q7_OFF,x
        bmi     @Done
        lda     L0A00
        sta     .last_val
        lda     #$ff       ;sync bytes
        sta     IWM_Q7_ON,x ;write first
        ora     IWM_Q6_OFF,x
        pha
        pla
        nop
        ldy     #$04       ;write 5 more
@Loop   pha
        pla
        jsr     DiskWriteByte2
        dey
        bne     @Loop
        lda     #$d5       ;write data prologue
        jsr     DiskWriteByte
        lda     #$aa
        jsr     DiskWriteByte
        lda     #$ad
        jsr     DiskWriteByte
        tya
        ldy     #$56
        bne     @SkipFwd   ;(always)

@Loop1  lda     L0A00,y    ;get data
@SkipFwd
        eor     L0A00-1,y  ;exclusive-or with prev
        tax
        lda     rwts_encode62,x ;get 6&2 value
        ldx     .slot
        sta     IWM_Q6_ON,x
        lda     IWM_Q6_OFF,x
        dey
        bne     @Loop1
        lda     .last_val
        nop
@Loop2  eor     $0900,y
        tax
        lda     rwts_encode62,x
        ldx     rwts_slot
        sta     IWM_Q6_ON,x
        lda     IWM_Q6_OFF,x
        lda     $0900,y
        iny
        bne     @Loop2
        tax
        lda     rwts_encode62,x ;get the last one
        ldx     .slot
        jsr     DiskWriteByte3 ;write it
        lda     #$de       ;write the data epilogue
        jsr     DiskWriteByte
        lda     #$aa
        jsr     DiskWriteByte
        lda     #$eb
        jsr     DiskWriteByte
        lda     #$ff
        jsr     DiskWriteByte
        lda     IWM_Q7_OFF,x ;turn off write mode
@Done   lda     IWM_Q6_OFF,x ;turn on read mode
        rts

; 
; Reads the header from the next address field to pass by.
; 
; Appears to be the same as the RDADR routine in DOS 3.3 ($B944).
; 
        !zone   Z008fee
.max_tries =    $6e
.chksum =       $6f
DiskReadNextAddr
        ldy     #$fc       ;3 * 256 + 3 = 771 attempts
        sty     .max_tries
@Retry  iny
        bne     @RdLoop
        inc     .max_tries
        beq     @Fail
@RdLoop lda     IWM_Q6_OFF,x ;read a byte
        bpl     @RdLoop
@CheckD5
        cmp     #$d5       ;look for D5 AA 96
        bne     @Retry
        nop
@RdLoop1
        lda     IWM_Q6_OFF,x ;got D5, look for AA
        bpl     @RdLoop1
        cmp     #$aa
        bne     @CheckD5
        ldy     #$03       ;set Y-reg=3 (read 4 bytes)
@RdLoop2
        lda     IWM_Q6_OFF,x
        bpl     @RdLoop2
        cmp     #$96
        bne     @CheckD5   ;note carry is set when byte matches
        lda     #$00       ;init checksum
@HdrFieldLoop
        sta     .chksum
@RdLoop3
        lda     IWM_Q6_OFF,x ;read odd bits
        bpl     @RdLoop3   ;A-reg=1a1c1e1g
        rol                ;A-reg=a1c1e1g1
        sta     .max_tries ;re-use as temp var
@RdLoop4
        lda     IWM_Q6_OFF,x ;read even bits
        bpl     @RdLoop4   ;A-reg=1b1d1f1h
        and     .max_tries ;merge: A-reg=abcdefgh
        sta     rwts_addr_fields,y
        eor     .chksum
        dey
        bpl     @HdrFieldLoop
        tay
        bne     @Fail
@RdLoop5
        lda     IWM_Q6_OFF,x ;look for epilogue DE AA
        bpl     @RdLoop5
        cmp     #$de
        bne     @Fail
        nop
@RdLoop6
        lda     IWM_Q6_OFF,x
        bpl     @RdLoop6
        cmp     #$aa
        bne     @Fail
        clc
        rts

@Fail   sec
        rts

; 
; Seek to desired track.  Essentially the same as SEEKABS in DOS 3.3 ($B9A0).
; 
; On entry:
;   A-reg: whole track number (0-34)
;   X-reg: slot number * 16
; 
; 
        !zone   Z00904c
.slot   =       $6e
.target_track = $6f
.htrack_count = $70
.cur_track =    $71
DiskSeekToTrack
        stx     .slot      ;save slot index
        asl                ;double track number (half-tracks)
        cmp     rwts_current_track ;already there?
        beq     Return7    ;yes, bail
        sta     .target_track
        lda     #$00
        sta     .htrack_count
; Update the current track number to point to the next half-track.
@SeekLoop
        lda     rwts_current_track
        sta     .cur_track ;compute delta between current and target
        sec
        sbc     .target_track
        beq     @Finish    ;we're there, finish up
        bcs     @MovingIn  ;current is larger, branch
        eor     #$ff       ;make positive; note we implicitly subtract 1
        inc     rwts_current_track ;moving toward outside of disk
        bcc     @Cont      ;(always)

@MovingIn
        adc     #$fe       ;carry is set, so this adds $FF (subtracts 1)
        dec     rwts_current_track
@Cont   cmp     .htrack_count
        bcc     @L9A78
        lda     .htrack_count
@L9A78  cmp     #$0c       ;after 12 iterations, don't update Y-reg
        bcs     @NoUpdateY
        tay
@NoUpdateY
        sec
        jsr     TrackStep
        lda     seek_delay0,y
        jsr     DiskDelay  ;pause to let head move
        lda     .cur_track ;previous track
        clc
        jsr     TrackStep2 ;move head, call with carry clear
        lda     seek_delay1,y
        jsr     DiskDelay  ;pause to let head move
        inc     .htrack_count
        bne     @SeekLoop  ;(always)
@Finish jsr     DiskDelay
        clc
; Turn on the appropriate stepper motor.  Phase is determined by the target
; track and the carry flag.
TrackStep
        lda     rwts_current_track
TrackStep2
        and     #$03
        rol
        ora     .slot
        tax
        lda     IWM_PH0_OFF,x
        ldx     .slot
Return7 rts

; Arm move delay routine.  Delays for the specified number of 100usec intervals
; (A-reg).
; 
; Timing-critical, must not span a page boundary.
DiskDelay
        ldx     #$11
@Loop1  dex
        bne     @Loop1
        inc     rwts_delay_ctr
        bne     @Loop2
        inc     rwts_delay_ctr+1
@Loop2  sec
        sbc     #$01
        bne     DiskDelay
        rts

seek_delay0
        !hex    01302824201e1d1c1c1c1c1c
seek_delay1
        !hex    702c26221f1e1d1c1c1c1c1c

; 
; Encodes 256 bytes into 6&2 format.
; 
; Same as DOS 3.3 PRENIBBLE routine ($B800).
; 
DiskEncode62
        ldx     #$00
        ldy     #$02
@Loop   dey
        lda     data_buffer,y
        lsr
        rol     L0A00,x
        lsr
        rol     L0A00,x
        sta     $0900,y
        inx
        cpx     #$56
        bcc     @Loop
        ldx     #$00
        tya
        bne     @Loop
        ldx     #$55
@Loop1  lda     L0A00,x
        and     #$3f
        sta     L0A00,x
        dex
        bpl     @Loop1
        rts

; 
; Decodes 342 bytes of 6&2 data to 256 bytes.
; 
; Same as DOS 3.3 POSTNIBBLE routine ($B8C2).
; 
DiskDecode62
        ldy     #$00
@Loop1  ldx     #$56
@Loop2  dex
        bmi     @Loop1
        lda     $0900,y    ;raw data buffer
        lsr     L0A00,x    ;twos buffer
        rol
        lsr     L0A00,x    ;twos buffer
        rol
        sta     data_buffer,y ;cooked data buffer
        iny
        bne     @Loop2
        rts

DiskWriteByte
        clc
DiskWriteByte2
        pha
        pla
DiskWriteByte3
        sta     IWM_Q6_ON,x
        ora     IWM_Q6_OFF,x
        rts

rwts_sect_skew
        !hex    000d0b09070503010e0c0a080604020f
rwts_decode62
        !hex    0001989902039c040506a0a1a2a3a4a50708a8a9aa090a0b0c0db0b10e0f1011
        !hex    1213b81415161718191ac0c1c2c3c4c5c6c7c8c9ca1bcc1c1d1ed0d1d21fd4d5
        !hex    2021d822232425262728e0e1e2e3e4292a2be82c2d2e2f303132f0f133343536
        !hex    3738f8393a3b3c3d3e3f

; 
; Scrambles save-game data.  Updates the RNG state and records it to the game
; file, then uses it to scramble the data.
; 
ScrambleSaveData
        lda     scramble_thing
        eor     rng_state
        sta     rng_state
        sta     scram_rng_seed
        eor     #$a5
        ora     #$11
        eor     rng_state+1
        sta     rng_state+1
        sta     scram_rng_seed+1
        eor     rng_state+2
        eor     #$f8
        sta     rng_state+2
        sta     scram_rng_seed+2
        eor     rng_state+3
        eor     #$12
        sta     rng_state+3
        sta     scram_rng_seed+3
DoScrambleSave
        ldy     #$69
@L9BC6  jsr     SaveScramble
        eor     scram_save_data,y
        sta     scram_save_data,y
        dey
        bpl     @L9BC6
        rts

UnscrambleSaveData
        ldy     #$03
@L9BD5  lda     scram_rng_seed,y ;restore the RNG seed
        sta     rng_state,y
        dey
        bpl     @L9BD5
        bmi     DoScrambleSave ;twice to undo

hi_res_pixel
        !hex    01020408102040
hi_res_2pixel
        !hex    83868c98b0e0c0
rt_end_pixels
        !hex    83878f9fbfffff
lf_end_pixels
        !hex    fffefcf8f0e0c0
; 
; Low byte of the address of a row on the text screen.  The high byte is
; computed directly.
; 
; Values are offset by 2 because the text and hi-res text appear in the same
; places, and we need to leave room for the hi-res window frame..
; 
text_addr_lo
        !hex    02820282028202822aaa2aaa2aaa2aaa52d252d252d252d2
; 
; Hi-res row base address table.  This only has the entries for every 8th line,
; because you can trivially add $400 for the next 7.
; 
hires_line_lo
        !hex    008000800080008028a828a828a828a850d050d050d050d0
hires_line_hi
        !hex    202021212222232320202121222223232020212122222323
        !text   "        "
hires_line_hi2
        !hex    3c3c3d3d3e3e3f3f3c3c3d3d3e3e3f3f3c3c3d3d3e3e3f3f

; 
; Draws a line.  Pixels are XORed.  The end coordinate is exclusive, to avoid a
; situation where we draw then erase every vertex with an even number of edges.
; 
; On entry:
;   $6e/6f: x0,y0
;   $70/71: x1,y1
; 
; On exit:
;   Y-reg preserved
; 
        !zone   Z009264
.row_div8 =     $06
.row_mod8 =     $07
.hptr   =       $0a
.delta_x =      $31
.x0     =       $6e
.y0     =       $6f
.x1     =       $70
.y1     =       $71
.delta_y =      $ad
.pixel_mask =   $ae
.err_term =     $af
.saved_y =      $b1
.saved_x =      $d0
DrawLine
        sty     .saved_y
        lda     #$80       ;init line error to 1/2
        sta     .err_term
        asl                ;A-reg=0 and C=1
        sta     lcoord_swap_flag
        lda     .x1        ;compute deltaX
        sbc     .x0
        bcs     @PosX
        eor     #$ff       ;was < 0, negate
        adc     #$01
        sec
@PosX   sta     .delta_x
        lda     .y1        ;compute deltaY
        sbc     .y0
        bcs     @PosY
        eor     #$ff       ;was < 0, negate
        adc     #$01
@PosY   sta     .delta_y
        cmp     .delta_x   ;mostly horizontal?
        bcc     DrawLineHorizDom ;yes, branch
        jmp     DrawLineVertDom

; Draw a horizontally-dominant line.
DrawLineHorizDom
        ldx     .x0        ;is X0 on the left?
        cpx     .x1
        bcc     @NoSwap    ;yes, render as-is
        dec     lcoord_swap_flag ;set flag (to $FF)
        lda     .x1        ;swap X0,Y0 with X1,Y1 to ensure that we're
        sta     .x0        ; drawing from left to right
        stx     .x1
        tax
        lda     .y1
        ldy     .y0
        sta     .y0
        sty     .y1
@NoSwap lda     .y0        ;divide Y0 by 8
        lsr
        lsr
        lsr
        sta     .row_div8
        tay
        lda     hires_line_lo,y ;look up base address, low byte
        sta     .hptr      ;set low byte of address
        lda     .y0        ;get Y0 again
        and     #$07       ;compute Y0 mod 8
        sta     .row_mod8
        asl                ;multiply by 4
        asl
        adc     hires_line_hi,y ;add to the base address, high byte
        sta     .hptr+1    ;set high byte of address
        ldy     mod7_table,x ;get X0 mod 7 (bit offset within byte)
        lda     hi_res_pixel,y ;convert to pixel mask
        sta     .pixel_mask
        ldy     div7_table,x ;get X0 divided by 7 (byte offset)
        ldx     .delta_y   ;check delta Y
        bne     @NotHoriz  ;nonzero, so not a horizontal line
        txa                ;A-reg=0
        beq     @CheckDir  ;(always)
; Compute error term adjustment (deltaX / deltaY).  This takes about 35 cycles,
; but reduces the cost per pixel, making it a win for longer lines.
; 
; For example, if deltaX=$0e and deltaY=$19, the result is $8e.  This
; corresponds to 14/25=0.56. (255 * 0.56 = 142.8 = $8e).
@NotHoriz
        lda     math_table2,x
        ldx     .delta_x
        sec
        sbc     math_table2,x
        ldx     .delta_y
        lda     math_table1,x
        ldx     .delta_x
        sbc     math_table1,x
        bcc     @L9CEB
        lda     #$ff
        bne     @CheckDir  ;(always)

@L9CEB  tax
        lda     math_table3,x
; Setup complete, draw lines moving up or down.  (This is usually done with a
; simple bit of self-modifying code; here two separate routines are used.)
@CheckDir
        sta     .delta_y   ;set initial value
        sec
        ldx     .delta_x
        inx
        lda     .y1
        sbc     .y0        ;is y1 > y0?  (why not CMP?)
        bcs     @MoveDown  ;yes, so we're moving downward
        lda     lcoord_swap_flag ;are we starting at the end?
        bne     @SkipFirst ;yes, skip first pixel
        dex                ;DEX so we stop before the last pixel
@UpLoop lda     .pixel_mask ;XOR pixel with screen value
        eor     (.hptr),y
        sta     (.hptr),y
@SkipFirst
        asl     .pixel_mask ;moving right, so pixel value moves left
        bpl     @SameByte  ;didn't shift into high bit, branch
        lda     #$01       ;we hit $80, so start over at $01
        sta     .pixel_mask
        iny                ;advance to next byte
@SameByte
        lda     .err_term  ;update error term
        adc     .delta_y   ;(carry cleared by pixel-mask ASL)
        sta     .err_term
        bcc     @SameLine  ;didn't roll, still on same line
        dec     .row_mod8  ;decrement mod8 counter
        bmi     @UpdateAddr8 ;rolled, do bigger calculation
        lda     .hptr+1    ;within a set of 8 lines we can just subtract 4
        sbc     #$04       ; from the high byte
        sta     .hptr+1
@SameLine
        dex                ;done yet?
        bne     @UpLoop    ;no, keep going
        ldy     .saved_y   ;restore Y-reg
        rts

@UpdateAddr8
        lda     #$07       ;reset the mod8 counter
        sta     .row_mod8
        stx     .saved_x
        ldx     .row_div8  ;advance the divided-by-8 row value
        dex
        stx     .row_div8
        lda     hires_line_lo,x ;get the address
        sta     .hptr
        lda     hires_line_hi2,x ;we're at an 8-line boundary, so no need to
        ldx     .saved_x   ; add anything here
        sta     .hptr+1
        jmp     @SameLine  ;back to it

@MoveDown
        lda     .row_mod8  ;this acts as a counter, so the distance to the next
        eor     #$07       ; 8-line boundary is (7 - row_mod8)
        sta     .row_mod8  ; which we can compute with a simple EOR
; (See :UpLoop -- this is the same code, just moving downward.)
        lda     lcoord_swap_flag
        beq     @L9D54
        dex
@DnLoop lda     .pixel_mask
        eor     (.hptr),y
        sta     (.hptr),y
@L9D54  asl     .pixel_mask
        bpl     @L9D5D
        lda     #$01
        sta     .pixel_mask
        iny
@L9D5D  lda     .err_term
        adc     .delta_y
        sta     .err_term
        bcc     @L9D6F
        dec     .row_mod8
        bmi     @L9D75
        lda     .hptr+1
        adc     #$03
        sta     .hptr+1
@L9D6F  dex
        bne     @DnLoop
        ldy     .saved_y
        rts

@L9D75  lda     #$07
        sta     .row_mod8
        stx     .saved_x
        ldx     .row_div8
        inx
        stx     .row_div8
        lda     hires_line_lo,x
        sta     .hptr
        lda     hires_line_hi,x
        sta     .hptr+1
        ldx     .saved_x
        jmp     @L9D6F

; Draw a vertically-dominant line.
DrawLineVertDom
        ldy     .y0        ;is Y0 on the bottom?
        tya
        ldx     .x0
        cpy     .y1
        bcs     @NoSwap    ;yes, render as-is
        dec     lcoord_swap_flag ;set flag (to $FF)
        lda     .x1        ;swap X0,Y0 with X1,Y1 to ensure that we're
        sta     .x0        ; drawing from bottom to top
        stx     .x1
        tax
        lda     .y1
        sta     .y0
        sty     .y1
        tay
@NoSwap lsr                ;divide Y0 by 8
        lsr
        lsr
        sta     .row_div8
        tay
        lda     hires_line_lo,y ;look up base address, low byte
        sta     .hptr      ;set low byte of address
        lda     .y0        ;get Y0 again
        and     #$07       ;compute Y0 mod 8
        sta     .row_mod8
        asl                ;multiply by 4
        asl
        adc     hires_line_hi,y ;add to the base address, high byte
        sta     .hptr+1    ;set high byte of address
        ldy     mod7_table,x ;get X0 mod 7 (bit offset within byte)
        lda     hi_res_pixel,y ;convert to pixel mask
        sta     .pixel_mask
        ldy     div7_table,x ;get X0 divided by 7 (byte offset)
        ldx     .delta_x   ;check delta X
        beq     @IsVert    ;it's zero, this is a vertical line
; Compute error term adjustment (deltaY / deltaX).  Takes about 35 cycles.
        lda     math_table2,x
        ldx     .delta_y
        sec
        sbc     math_table2,x
        ldx     .delta_x
        lda     math_table1,x
        ldx     .delta_y
        sbc     math_table1,x
        bcc     @L9DE9
        lda     #$ff
        bne     @L9DED

@L9DE9  tax
        lda     math_table3,x
; Setup complete, draw lines toward left or right.
@L9DED  sta     .delta_x   ;set initial value
@IsVert sec
        ldx     .delta_y
        inx
        lda     .x1
        sbc     .x0        ;is x1 < x0?
        bcc     @RightToLeft ;yes, draw right to left
        clc
        lda     lcoord_swap_flag ;are we starting at the end?
        beq     @SkipFirst ;yes, skip first pixel
        dex                ;DEX so we stop before the last pixel
@RightLoop
        lda     .pixel_mask ;XOR pixel with screen value
        eor     (.hptr),y
        sta     (.hptr),y
@SkipFirst
        dec     .row_mod8  ;decrement mod8 counter
        bmi     @L9E28     ;rolled, do bigger calculation
        lda     .hptr+1    ;within a set of 8 lines we can just subtract 4
        sbc     #$03       ; from the high byte
        sta     .hptr+1    ;(should've gone top-down; carry would be clear)
        clc
@L9E11  lda     .err_term  ;update error term
        adc     .delta_x
        sta     .err_term
        bcc     @SameCol   ;didn't roll, still in same pixel column
        asl     .pixel_mask ;moving right, so shift left
        bpl     @SameCol   ;still in same byte, branch
        lda     #$01       ;new byte, reset pixel mask
        sta     .pixel_mask
        iny                ;and advance to next byte
@SameCol
        dex                ;done yet?
        bne     @RightLoop ;no, keep going
        ldy     .saved_y   ;restore Y-reg
        rts

@L9E28  lda     #$07
        sta     .row_mod8
        stx     .saved_x
        ldx     .row_div8
        dex
        stx     .row_div8
        lda     hires_line_lo,x
        sta     .hptr
        lda     hires_line_hi2,x
        ldx     .saved_x
        sta     .hptr+1
        jmp     @L9E11

@RightToLeft
        lda     lcoord_swap_flag
        beq     L9E4E
        dex
LeftLoop
        lda     .pixel_mask
        eor     (.hptr),y
        sta     (.hptr),y
L9E4E   dec     .row_mod8
        bmi     L9E71
        lda     .hptr+1
        sbc     #$03
        sta     .hptr+1
        clc
L9E59   lda     .err_term
        adc     .delta_x
        sta     .err_term
        bcc     @L9E6B
        lsr     .pixel_mask ;moving left, shift right
        bcc     @L9E6B     ;didn't shift mask into carry, still good
        lda     #$40
        sta     .pixel_mask
        dey
        clc
@L9E6B  dex
        bne     LeftLoop
        ldy     .saved_y
Return8 rts

L9E71   lda     #$07
        sta     .row_mod8
        stx     .saved_x
        ldx     .row_div8
        dex
        stx     .row_div8
        lda     hires_line_lo,x
        sta     .hptr
        lda     hires_line_hi2,x
        ldx     .saved_x
        sta     .hptr+1
        jmp     L9E59

DrawDoubleHorizLine
        jsr     @DrawDoubleInc ;draw a line then fall through to draw another
@DrawDoubleInc
        inc     .y0
; 
; Draws a horizontal line in color.
; 
; As with the other line drawing routines, the end point is exclusive (last
; point not plotted).
; 
; On entry:
;   $35: color index ($00-18, even values only)
;   $6e: x0
;   $6f: y0
;   $70: x1
; 
; On exit:
;   Y-reg preserved
; 
        !zone   Z009490
.color0 =       $06
.color1 =       $07
.pixel_tmp =    $09
.hptr   =       $0a
.color_index =  $35
.x0     =       $6e
.y0     =       $6f
.x1     =       $70
.byte_count =   $ae
.saved_y =      $b1
DrawHorizLine
        sty     .saved_y   ;preserve Y-reg
        lda     .x0        ;strip low bit from X0
        and     #$fe
        sta     .x0
        tax                ;hold X0 in X-reg
        lda     .x1        ;strip low bit from X1
        and     #$fe
        sta     .x1
        cmp     .x0        ;is x1 > x0?
        beq     Return8    ;actually, x1==x0, nothing to do
        bcs     @L9EA8     ;yes, so we're moving left to right; branch
        stx     .x1        ;swap X0 with X1
        tax                ;get X0 (was X1) in X-reg
@L9EA8  lda     .y0        ;get row
        lsr                ;divide by 8
        lsr
        lsr
        tay
        lda     hires_line_lo,y ;base address for 8-line section
        sta     .hptr      ;save low byte
        lda     .y0        ;compute Y-coord mod 8
        and     #$07
        asl                ;multiply by 4
        asl
        adc     hires_line_hi,y ;compute hi-res address, high byte
        sta     .hptr+1
        lda     div7_table,x ;compute X coord / 7
        and     #$01       ;mask off all but low bit for odd/even
        ora     .color_index ;merge with color index
        tay
        lda     color_masks,y ;get color pixel masks
        sta     .color0
        lda     color_masks+1,y
        sta     .color1
        ldy     .x1        ;get end coordinate
        lda     div7_table-2,y ;compute (X1 - 2) / 7  (we don't plot last point)
        ldy     mod7_table,x ;compute X0 mod 7
        sec
        sbc     div7_table,x ;(X1 - 2) / 7 - (X0 / 7)
        sta     .byte_count ;this is number of bytes we will update
        lda     lf_end_pixels,y ;get pixels for start of line
        and     .color0    ;apply color mask
        ldy     div7_table,x ;get byte offset (X0 / 7)
        ldx     .byte_count ;check if line fits in single byte
        beq     @SwapColor ;it does, swap the color and jump to end-of-line
        sta     .pixel_tmp
        lda     (.hptr),y  ;blend with screen contents
        and     #$7f       ;but don't touch the high bit
        eor     .pixel_tmp
        sta     (.hptr),y
        iny                ;advance to next byte
        dex                ;decrement counter
        beq     @EndOfLine ;if zero, go handle the rightmost byte
; Do the "middle" bytes.  The color alternates, so we do two at a time.
@WholeByteLoop
        lda     (.hptr),y
        and     #$7f
        eor     .color1
        sta     (.hptr),y
        iny
        dex                ;done?
        beq     @FinishWith0 ;yes; use color0 for end
        lda     (.hptr),y
        and     #$7f
        eor     .color0
        sta     (.hptr),y
        iny
        dex                ;done?
        bne     @WholeByteLoop ;not yet
@EndOfLine
        lda     .color1    ;use color1 for end
@EndOfLine1
        ldx     .x1
        ldy     mod7_table-2,x ;get bit column for last pixel (-2 because we don't
        cpy     #$06       ; plot the last pixel, and color pixels are 2 bits)
        and     rt_end_pixels,y ;merge pixels with right-end mask
        ldy     div7_table-2,x ;get byte position for last pixel
        sta     .pixel_tmp
        lda     (.hptr),y  ;blend with screen contents
        and     #$7f
        eor     .pixel_tmp
        sta     (.hptr),y
        bcc     @Done      ;if not in pixel column 6, we're done
        lda     #$81       ;need to update the first pixel in the next byte
        and     .color0    ; mask the color
        iny
        sta     .pixel_tmp
        lda     (.hptr),y  ;blend with screen contents
        and     #$7f
        eor     .pixel_tmp
        sta     (.hptr),y
@Done   ldy     .saved_y
        rts

@FinishWith0
        lda     .color0
@SwapColor
        ldx     .color1
        stx     .color0
        jmp     @EndOfLine1

color_masks
        !hex    0000
        !hex    0000
        !hex    552a
        !hex    5500
        !hex    2a55
        !hex    2a00
        !hex    7f7f
        !hex    7f00
        !hex    d5aa
        !hex    d500
        !hex    aad5
        !hex    aa00
        !hex    aaaa
        !hex    aa00

; 
; Draws a vertical line, in color.
; 
; On entry:
;   $6e: x0
;   $6f: y0
;   $71: y1
; 
; On exit:
;   Y-reg preserved
; 
        !zone   Z009562
.row_div8 =     $06
.row_mod8 =     $07
.pixel_mask1 =  $08
.pixel_tmp =    $09
.hptr   =       $0a
.color_index =  $35
.x0     =       $6e
.y0     =       $6f
.x1     =       $70
.y1     =       $71
.pixel_mask0 =  $ae
.saved_y =      $b1
.saved_x =      $d0
DrawVerticalLine
        sty     .saved_y   ;preserve Y
        lda     .y0
        cmp     .y1        ;y0 >= y1?
        bcs     @NoSwap    ;yes, branch
        ldy     .y1        ;no, swap
        sta     .y1
        tya
@NoSwap ldx     .x0
        jsr     DrawColorPixel ;draw pixel at X0,Y0
        lda     .y0        ;compute deltaY
        sec
        sbc     .y1
        beq     @Done
        tax
        inx
        jmp     @NextLine

; Continue drawing the line, using the pixel masks set up for the first pixel.
@DrawLoop
        lda     .pixel_mask0 ;blend first byte
        eor     (.hptr),y
        sta     (.hptr),y
        lda     .pixel_mask1 ;do we straddle the byte boundary?
        beq     @NextLine  ;no, skip 2nd byte
        iny                ;advance to next byte column
        eor     (.hptr),y  ;blend
        sta     (.hptr),y
        dey                ;back up
@NextLine
        dec     .row_mod8  ;decrement local 8 count
        bmi     @Recalc8   ;rolled, recompute
        lda     .hptr+1    ;update row address by simply subtracting
        sec                ; four from the high byte
        sbc     #$04
        sta     .hptr+1
@Cont   dex                ;decrement count
        bne     @DrawLoop
@Done   ldy     .saved_y
        rts

@Recalc8
        lda     #$07       ;reset local 8 count
        sta     .row_mod8
        stx     .saved_x   ;preserve X-reg
        ldx     .row_div8  ;update 8-line section index
        dex
        stx     .row_div8
        lda     hires_line_lo,x ;compute new row address
        sta     .hptr
        lda     hires_line_hi2,x
        ldx     .saved_x
        sta     .hptr+1
        jmp     @Cont

; 
; Draws a color (two-bit) pixel.
; 
; On entry:
;   X-reg: x0
;   A-reg: y0
; 
; On exit:
;   $ae: pixel mask 0
;   $08: pixel mask 1
; 
DrawColorPixel
        sta     .y0        ;divide y0 by 8
        lsr
        lsr
        lsr
        sta     .row_div8
        tay
        lda     hires_line_lo,y ;set hi-res address, low byte
        sta     .hptr
        lda     .y0        ;compute y0 mod 8
        and     #$07
        sta     .row_mod8
        asl                ;multiply by 4
        asl
        adc     hires_line_hi,y ;compute hi-res address, high byte
        sta     .hptr+1
        ldy     mod7_table,x ;compute x0 mod 7
        lda     #$00       ;init mask to zero
        cpy     #$06       ;at right edge of byte (2-pixel straddles bytes)?
        bne     @L9FE0     ;no
        lda     #$81       ;yes, use nonzero mask
@L9FE0  sta     .pixel_mask1
        lda     hi_res_2pixel,y ;get two-pixel pattern for this offset
        sta     .pixel_mask0
        lda     div7_table,x ;compute X0 / 7
        and     #$01       ;get odd/even bit
        ora     .color_index ;merge with color index
        tay
        lda     color_masks+1,y ;get the color mask for the second byte
        and     .pixel_mask1 ;and it with the mask (so we keep either the leftmost
        sta     .pixel_mask1 ; pixel, or no pixels)
        lda     color_masks,y ;get color mask for first byte
        and     .pixel_mask0 ;merge with two-pixel mask
        sta     .pixel_mask0
        ldy     div7_table,x ;compute X0 / 7 (byte column)
        eor     (.hptr),y  ;blend with screen contents
        sta     (.hptr),y
        lda     .pixel_mask1 ;do we need to do the second byte?
        beq     @Done      ;no
        iny                ;yes, advance to next byte
        eor     (.hptr),y  ; and blend with screen contents
        sta     (.hptr),y
        dey
@Done   rts

ActivateEcm
        lda     #$20
        sta     ecm_active_flag
LA013   lda     #$2a
        ldx     #$38
        bne     LA01D

LA019   lda     #$2d
        ldx     #$c0
LA01D   sta     $31
        lda     #$a0
        sta     $32
        lda     #$16
        sta     text_vposn
        jmp     LA14C

        !hex    7f7f077f7f077f7f707f7f

DrawIndicator
        tya
        pha
        jsr     @LA03E
        pla
        sta     color_indices,x
@LA03E  lda     color_indices,x
        beq     LA07C
        sta     .color_index
        lda     hud_xcoords-1,x
        sta     .x0
        clc
        adc     #$06
        sta     .x1
        txa
        pha
        lda     #184
        sta     .y0
        jsr     DrawDoubleHorizLine ;draw 4 lines total
        jsr     DrawDoubleHorizLine
        pla
        tax
        tya
        ldy     #$00
        rts

hud_xcoords
        !hex    2820181020ffffc9809004a9071860c920b008c90df004c915d0f0

LA07C   clc
        rts

Delay   pha
        txa
        pha
        tya
        pha
        ldy     #$0f
        ldx     #$00
@LA087  dex
        bne     @LA087
        dey
        bne     @LA087
        pla
        tay
        pla
        tax
        pla
        rts

Unref1  cmp     #$7b
        bcs     @LA0A4
        cmp     #$0d
        bcc     @LA0A4
        bne     OutputChar
        lda     #$0c
        jsr     OutputChar
        lda     #$0d
@LA0A4  clc
        rts

CtrlGBeep
        jsr     MakeNoise3
        jmp     LA132

LA0AC   bit     display_mode_flag
        bpl     @LA0B8
        jsr     ClearTextScreen
        lda     $38
        jmp     LA0F4

@LA0B8  jsr     ClearViewportArea
        lda     $38
        jmp     LA0F4

; 
; Print a char to the text screen.
; 
; The sloppy upper-case conversion screws up text entry, e.g. if you type
; "[]<del>" for the commander name it comes out ";=_".
; 
PrintTextChar
        bit     ptb_lower_case ;lower-case mode enabled?
        bmi     @LowerOkay ;yes, it's fine
        cmp     #'['       ;is it lower case letter (or [\]^_)?
        bcc     @LowerOkay ;no, leave it
        sbc     #$20       ;yes, convert to upper case
@LowerOkay
        ora     #$80
        pha
        lda     text_addr_lo,y
        sta     .hptr
        tya
        and     #$07       ;compute the high byte
        lsr
        clc
        adc     #$04
        sta     .hptr+1
        txa
        tay
        pla
        sta     (.hptr),y
        jmp     LA130

OutputFF
        lda     #$0c
OutputChar
        sta     $38
        sty     $0286
        stx     $0285
        ldy     text_mod_flags
        cpy     #$ff
        beq     LA132
LA0F4   cmp     #$07       ;Ctrl+G?
        beq     CtrlGBeep  ;yes, beep
        cmp     #$20
        bcs     @LA10C
        cmp     #$0a
        beq     @LA104
@LA100  ldx     #$01
        stx     text_hposn
@LA104  cmp     #$0d
        beq     LA132
        inc     text_vposn
        bne     LA132
@LA10C  ldx     text_hposn
        cpx     #31
        bcc     @HposnOkay
        jsr     @LA100
        ldx     text_hposn
@HposnOkay
        ldy     text_vposn
        cpy     #24        ;off bottom of screen?
        bcs     LA0AC      ;yes, do something
        bit     display_mode_flag
        bmi     PrintTextChar
        pha                ;save char to print
        lda     text_hposn ;get text horizontal position
        asl                ;multiply by 7 and add 13
        asl
        asl
        adc     #$0d
        sbc     text_hposn
        tax
        pla
        jsr     PrintHiresChar
LA130   inc     text_hposn
LA132   ldy     $0286
        ldx     $0285
        lda     $38
        clc
        rts

; 
; Print a character on the hi-res screen.
; 
; Unlike most HRCGs, the horizontal offset is specified in pixels, and the glyph
; is bit-shifted in place.
; 
; On entry:
;   A-reg: char to print ($20-7f)
;   X-reg: pixel offset to print at
; 
        !zone   Z00973c
.first_col =    $06
.saved_y =      $07
.glyph_hi =     $08
.hptr   =       $0a
.glyph_ptr =    $31
.pixel_index =  $33
PrintHiresChar
        ldy     #(>font_glyphs)-1 ;start at -$100 because we INY later
        asl                ;multiply char by 4
        asl
        bcc     @LA144     ;branch if char value < $40 (numbers/symbols)
        ldy     #(>font_glyphs)+1 ;letters, start at $1Exx instead
@LA144  asl                ;multiply by 2 (8 bytes per glyph)
        bcc     @LA148     ;branch if char [00,1f] (not expected) or [40,5f]
        iny                ;char is [20,3f] or [60,7f], add one
@LA148  sta     .glyph_ptr
        sty     .glyph_ptr+1
LA14C   ldy     text_vposn ;get hi-res row address
        lda     hires_line_lo,y
        sta     .hptr
        lda     hires_line_hi,y
        sta     .hptr+1
        ldy     mod7_table,x ;get hi-res column and pixel index
        sty     .pixel_index
        ldy     div7_table,x
        sty     .first_col
        ldy     #$00       ;prepare glyph data
@GlyphLoop
        lda     #$00
        sta     .glyph_hi
        lda     (.glyph_ptr),y ;get byte for this row
        ldx     .pixel_index
@ShiftLoop
        cmp     #$80       ;shift it over, stepping across the high bit
        rol     .glyph_hi
        dex
        bmi     @LA177
        asl
        jmp     @ShiftLoop

@LA177  and     #$7f       ;clear high bit
        clc
        sty     .saved_y
        ldy     .first_col ;blend first half onto display
        eor     (.hptr),y
        sta     (.hptr),y
        iny
        lda     .glyph_hi  ;blend second half
        eor     (.hptr),y
        sta     (.hptr),y
        ldy     .saved_y
        lda     .hptr+1    ;update hi-res address
        adc     #$04
        sta     .hptr+1
        iny
        cpy     #$08       ;are we done (glyph height = 8)?
        bne     @GlyphLoop ;not yet
        rts

LA197   lda     displayed_screen
        beq     ClearAndDrawFrame
        cmp     #$0d
        beq     ClearAndDrawFrame
        and     #$c0
        bne     ClearAndDrawFrame
        jsr     ClearTextScreen
        jmp     ShowText

; 
; Erases $400-7ff to $A0 (high-ASCII space character).  Tramples screen holes.
; 
        !zone   Z0097a9
.ptr    =       $0a
ClearTextScreen
        ldy     #$00
        ldx     #$04
        sty     .ptr
        stx     .ptr+1
        lda     #' ' | $80
@Loop   sta     (.ptr),y
        iny
        bne     @Loop
        inc     .ptr+1
        dex
        bne     @Loop
        rts

ClearAndDrawFrame
        jsr     ClearViewportArea
        jsr     DrawWindowTopLine
        jsr     ShowHiRes
        rts

        !zone   Z0097c8
.ptr    =       $0a
.color_index =  $35
.x0     =       $6e
.y0     =       $6f
.x1     =       $70
DrawWindowTopLine
        ldx     #$00       ;draw from 0,0 to 255,0
        stx     .x0
        stx     .y0
        dex
        stx     .x1
        lda     #$10       ;blue
        sta     .color_index
        jsr     DrawHorizLine
        lda     #$aa
        sta     title_screen+1 ;unnecessary
        lda     #$aa
        sta     title_screen+37 ;needed because lines don't set the last pixel
        rts

ClearViewportArea
        ldy     #16        ;clear lines 0-16
@Loop   jsr     DrawFrameClearLine
        dey
        bpl     @Loop
        iny                ;Y=0
        sty     text_hposn
        sty     text_vposn
        rts

        !hex    a000840aa900860b910a88d0fb60a900910ac8d0fb60853460853660a000b15e ;unreferenced code?
        !hex    910a88d0f9e65fe60bcad0f260

ClearLines
        lda     #$00
        sta     PLAYER_STATE+54
        sta     $0278
        jsr     Vposn21_Hposn1
        lda     #$ff
        sta     txt_lcase_flag
        lda     #$80
        sta     text_mod_flags
        lda     display_mode_flag ;text mode?
        bpl     ClearLinesHiRes ;no, do on hi-res screen
        lda     #$20       ;print 64 spaces
        ldx     #$40
@Loop   jsr     OutputChar
        dex
        bne     @Loop
Vposn21_Hposn1
        lda     #21
        sta     text_vposn
        lda     #1
        sta     text_hposn
        rts

        !zone   Z009849
.counter =      $07
.hptr   =       $0a
ClearLinesHiRes
        ldy     #15        ;clear text line 15
        sty     text_vposn
        lda     #$01
        sta     text_hposn
        jsr     DrawFrameClearLine
        iny                ;clear text line 16
; 
; Clears 8 lines on the hi-res screen (equivalent to one line on the text
; screen), drawing the sides of the viewport window frame.
; 
; On entry:
;   Y-reg: text line (0-23)
; 
; On exit:
;   Y-reg: preserved
; 
DrawFrameClearLine
        lda     #$08       ;clear 8 hi-res lines
        sta     .counter
        ldx     hires_line_lo,y ;set hi-res base address
        stx     .hptr
        ldx     hires_line_hi,y
        tya                ;preserve Y-reg
        pha
@RowLoop
        stx     .hptr+1
        lda     #$a0       ;one pixel + high bit set on right edge
        ldy     #37        ;37 bytes in the middle
@MidLoop
        sta     (.hptr),y  ;set (not blend)
        lda     #$00       ;middle bytes are zero
        dey
        bne     @MidLoop
        lda     #$c0       ;one pixel + high bit set on left edge
        sta     (.hptr),y  ;store that
        iny                ;move back one right
        asl                ;just the high bit this time
        sta     (.hptr),y  ;set that
        inx                ;add 4 to the high byte of the address
        inx
        inx
        inx
        dec     .counter   ;are we done?
        bne     @RowLoop   ;no, keep going
        pla                ;restore Y-reg
        tay
LA282   rts

SCAN    lda     polyobj_vis
        and     #$10
        beq     LA282
        ldx     $b8
        bmi     LA282
        lda     L4E58,x
        sta     $35
        lda     INWK+1
        ora     INWK+4
        ora     polyobj_zpos_mi
        and     #$c0
        bne     LA282
        lda     INWK+1
        clc
        ldx     INWK+2
        bpl     @LA2A8
        eor     #$ff
        adc     #$01
        clc
@LA2A8  adc     #$7d
        and     #$fe
        sta     $6e
        tax
        dex
        dex
        lda     polyobj_zpos_mi
        lsr
        lsr
        clc
        ldy     polyobj_zpos_hi
        bpl     @LA2BD
        eor     #$ff
        sec
@LA2BD  adc     #$5b
        eor     #$ff
        sta     $71
        lda     INWK+4
        lsr
        clc
        ldy     INWK+5
        bmi     @LA2CE
        eor     #$ff
        sec
@LA2CE  adc     $71
        cmp     #$92
        bcs     @LA2D6
        lda     #$92
@LA2D6  cmp     #$bf
        bcc     @LA2DC
        lda     #$be
@LA2DC  jsr     DrawColorPixel
        jmp     DrawVerticalLine

; 
; Set the display to hi-res page 1.
; 
ShowHiRes
        lda     TXTPAGE1
        lda     MIXCLR
        lda     HIRES
        lda     TXTCLR
        lsr     display_mode_flag ;clears high bit
        rts

; 
; Set the display to show text page 1.
; 
ShowText
        lda     TXTPAGE1
        lda     TXTSET
        sec
        ror     display_mode_flag ;sets high bit
        rts

        !hex    836f63
; 
; Addresses of hull definitions, indexed by object type (1-32).  Entry 0 is not
; used, and entry 32 isn't used in most contexts: the space station entry (#2)
; will point to either the Coriolis or Dodecahedron station definition depending
; on which exists in the current system.
; 
hull_addr_lo
        !fill   1,$6f
hull_addr_hi
        !fill   1,$75
        !word   hull_missile ;1
station_addr
        !word   hull_coriolis
        !word   hull_escape ;3
plate_addr
        !word   hull_plate
        !word   hull_cargo
        !word   hull_boulder
        !word   hull_asteroid
        !word   hull_splinter
        !word   hull_shuttle
        !word   hull_transporter
        !word   hull_cobra_mk3 ;11
        !word   hull_python
        !word   hull_boa
        !word   hull_anaconda
        !word   hull_asteroid2
        !word   hull_viper
        !word   hull_sidewinder ;17 (first pirate)
        !word   hull_mamba
        !word   hull_krait
        !word   hull_adder
        !word   hull_gecko
        !word   hull_cobra_mk1
        !word   hull_worm
        !word   hull_cobra3_pir
        !word   hull_asp_mk2
        !word   hull_python_pir
        !word   hull_ferdelance
        !word   hull_moray
        !word   hull_thargoid ;29
        !word   hull_thargon ;30
        !word   hull_constrictor
dodo_addr
        !word   hull_dodo
; 
; Hull characteristics, one per ship type.  Indexing is from <table-1>, so the
; first byte is for ship type #1 (missile).
; 
; This appears to be what the BBC disasm refers to as "NEWB":
;  0000 0001: trader
;  0000 0010: hunter
;  0000 0100: angry
;  0000 1000: pirate
;  0001 0000: ?
;  0010 0000: innocent
;  0100 0000: cop
;  1000 0000: has escape pod
hull_NEWB
        !hex    00000100000000002161a0a0a0a1a1c20c8c8c8c0c8c058c8c8c820c0c040400
; 
; Kill value.  Added to kill score when a ship is destroyed by shooting it with
; a laser or missile (but not an energy bomb).
; 
; In the BBC Micro version everything was worth one point (equivalent to $0100
; here).  In C64/Apple II the value can vary.
; 
; Indexed by ship type (1-31), starting with type #1 (missile).
kill_score_lo
        !hex    9500100a0a06080a1011eaaad500551a5580555a55aa322a152a40c0aa215500
kill_score_hi
        !hex    0000000000000000000000000001000000000000000000010101010002000500
;*******************************************************************************
;* 3D mesh definitions.                                                        *
;*                                                                             *
;* Hull definitions start with a 20-byte header, and are followed by a list of *
;* vertices.  In most cases this is followed by the edges and faces, but for   *
;* some ships the edge/face data from another mesh is used.                    *
;*                                                                             *
;* Using the Escape Capsule as an example:                                     *
;*                                                                             *
;*  +00   $20    ;high nibble is scoop info, low nibble is debris spin info    *
;*  +01   $0100  ;two-byte missile lock data                                   *
;*  +03   $2c    ;low byte of offset to edge data                              *
;*  +04   $44    ;low byte of offset to face data                              *
;*  +05   $1d    ;(4 * maxlines + 1) for ship lines stack                      *
;*  +06   $00    ;gun vertex * 4                                               *
;*  +07   $16    ;explosion count, e.g. $2A = 4*n+6                            *
;*  +08   $18    ;vertex count * 6 (byte count)                                *
;*  +09   $06    ;edge count                                                   *
;*  +0a   $0000  ;bounty value (in 0.1 Cr)                                     *
;*  +0c   $10    ;face count * 4 (byte count)                                  *
;*  +0d   $08    ;LOD distance; past this it's just drawn as a dot             *
;*  +0e   $11    ;energy (hit points)                                          *
;*  +0f   $08    ;speed                                                        *
;*  +10   $00    ;high byte of offset to edge data                             *
;*  +11   $00    ;high byte of offset to face data                             *
;*  +12   $04    ;down-scaling of normals (larger value -> smaller ship)       *
;*  +13   $00    ;00LLLMMM laser power and missile count                       *
;*                                                                             *
;* Vertices:                                                                   *
;*  +0/1/2: unsigned X/Y/Z value                                               *
;*  +3: flags XYZV VVVV                                                        *
;*      X/Y/Z = 1 if coordinate value is negative                              *
;*      VVVVV = visibility cutoff                                              *
;*  +4/5: four face indexes (one per nibble), for visibility test              *
;*      (if fewer than 4 are relevant, one is repeated)                        *
;*  .bulk   $07,$00,$24,$9f, $12,$33 ;-$07, $00, $24 / faces 1,2,3             *
;*  .bulk   $07,$0e,$0c,$ff, $02,$33 ;-$07,-$0e,-$0c / faces 0,2,3             *
;*  .bulk   $07,$0e,$0c,$bf, $01,$33 ;-$07, $0e,-$0c / faces 0,1,3             *
;*  .bulk   $15,$00,$00,$1f, $01,$22 ; $15, $00, $00 / faces 0,1,2             *
;*                                                                             *
;* Edges:                                                                      *
;*  +0: flags 000V VVVV                                                        *
;*      VVVVV = visibility cutoff                                              *
;*  +1: two face indices (one per nibble), for visibility test                 *
;*  +2/3: vertex index * 4                                                     *
;*  .bulk   $1f,$23,$00,$04 ;vertices 0,1 / faces 2,3                          *
;*  .bulk   $1f,$03,$04,$08 ;vertices 1,2 / faces 0,3                          *
;*  .bulk   $1f,$01,$08,$0c ;vertices 2,3 / faces 0,1                          *
;*  .bulk   $1f,$12,$0c,$00 ;vertices 3,0 / faces 1,2                          *
;*  .bulk   $1f,$13,$00,$08 ;vertices 0,2 / faces 1,3                          *
;*  .bulk   $1f,$02,$0c,$04 ;vertices 3,1 / faces 0,2                          *
;*                                                                             *
;* Faces:                                                                      *
;*  +0: flags: XYZV VVVV                                                       *
;*      X/Y/Z = 1 if coordinate value is negative                              *
;*      VVVVV = always-visible cutoff                                          *
;*  +1/2/3: face normal x/y/z                                                  *
;*  .bulk   $3f,$34,$00,$7a ; $34, $00,-$7a                                    *
;*  .bulk   $1f,$27,$67,$1e ; $27, $67, $1e                                    *
;*  .bulk   $5f,$27,$67,$1e ; $27,-$67, $1e                                    *
;*  .bulk   $9f,$70,$00,$00 ;-$70, $00, $00                                    *
;*                                                                             *
;* Mesh definitions are commonly structured as a list of vertices and a list   *
;* of faces, where each face is a list of vertex indices.  This works          *
;* differently.                                                                *
;*                                                                             *
;* There is still a list of vertices, but what's drawn is a list of edges.     *
;* Each vertex has a set of 1-4 associated faces, and each edge has a set of   *
;* 1-2 associated faces.  Each face is just a normal vector used to determine  *
;* visibility for backface removal.  For each vertex and edge, if at least one *
;* associated face is visible, the item is considered visible.                 *
;*                                                                             *
;* This arrangement allows the code to quickly discard vertices that aren't    *
;* part of a visible edge.  It also provides a way for edges that aren't part  *
;* of a face, e.g. the prongs on the Krait, to be excluded: if the two nearby  *
;* faces aren't visible, the prong isn't drawn.  (It's not perfect, but at     *
;* 280x192 you'll never notice.)                                               *
;*                                                                             *
;* If the ship is very far away, it's not drawn.  If it's closer but still too *
;* far to have a distinct shape, determined by the Level of Detail (LOD)       *
;* value, it's drawn as a dot.  When it's close enough to see clearly, the     *
;* distance is compared to the 5-bit visibility limit that is encoded into     *
;* each vertex and edge.  If the distance is greater than the limit, the       *
;* element is not drawn.  This provides a second LOD test, allowing fine       *
;* details (like the cabin window on the Krait) to be excluded while the ship  *
;* is still far away.                                                          *
;*                                                                             *
;* The visibility limit works differently for faces: if the ship is outside    *
;* the visibility limit, the face is *always* visible, regardless of backface  *
;* tests.  You can see this used on the "plate / alloys" hull, which has a     *
;* single face that is always visible (limit=0).                               *
;*******************************************************************************
hull_missile
        !byte   $00
        !word   $0640
        !byte   $7a        ;edge data offset low
        !byte   $da
        !byte   $55
        !byte   $00
        !byte   $0a
        !byte   $66        ;vertex count * 6 (byte count)
        !byte   $18        ;edge count
        !word   0
        !byte   $24        ;face count * 4 (byte count)
        !byte   $0e
        !byte   2
        !byte   44
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00000000
        !hex    0000441f1032 ;vertices
        !hex    0808245f2154
        !hex    0808241f3274
        !hex    0808249f3076
        !hex    080824df1065
        !hex    08082c3f7488
        !hex    08082c7f5488
        !hex    08082cff6588
        !hex    08082cbf7688
        !hex    0c0c2c287488
        !hex    0c0c2c685488
        !hex    0c0c2ce86588
        !hex    0c0c2ca87688
        !hex    08080ca87677
        !hex    08080ce86566
        !hex    08080c287477
        !hex    08080c685455
        !hex    1f210004   ;edges
        !hex    1f320008
        !hex    1f30000c
        !hex    1f100010
        !hex    1f240408
        !hex    1f510410
        !hex    1f600c10
        !hex    1f73080c
        !hex    1f740814
        !hex    1f540418
        !hex    1f65101c
        !hex    1f760c20
        !hex    1f861c20
        !hex    1f871420
        !hex    1f841418
        !hex    1f85181c
        !hex    08851828
        !hex    08871424
        !hex    08872030
        !hex    08851c2c
        !hex    0874243c
        !hex    08542840
        !hex    08763034
        !hex    08652c38
        !hex    9f400010   ;faces
        !hex    5f004010
        !hex    1f400010
        !hex    1f004010
        !hex    1f200000
        !hex    5f002000
        !hex    9f200000
        !hex    1f002000
        !hex    3f0000b0
; Coriolis space station.
hull_coriolis
        !byte   $00
        !word   $6400
        !byte   $74
        !byte   $e4
        !byte   $59
        !byte   $00
        !byte   $36
        !byte   $60
        !byte   $1c
        !word   0
        !byte   $38
        !byte   $78
        !byte   240
        !byte   0
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   %00000110
        !hex    a000a01f1062 ;vertices
        !hex    00a0a01f2083
        !hex    a000a09f3074
        !hex    00a0a05f1054
        !hex    a0a0005f51a6
        !hex    a0a0001f62b8
        !hex    a0a0009f73c8
        !hex    a0a000df5497
        !hex    a000a03fa6db
        !hex    00a0a03fb8dc
        !hex    a000a0bf97dc
        !hex    00a0a07f95da
        !hex    0a1ea05e0000
        !hex    0a1ea01e0000
        !hex    0a1ea09e0000
        !hex    0a1ea0de0000
        !hex    1f10000c   ;edges
        !hex    1f200004
        !hex    1f300408
        !hex    1f40080c
        !hex    1f510c10
        !hex    1f610010
        !hex    1f620014
        !hex    1f821404
        !hex    1f830418
        !hex    1f730818
        !hex    1f74081c
        !hex    1f540c1c
        !hex    1fda202c
        !hex    1fdb2024
        !hex    1fdc2428
        !hex    1fd9282c
        !hex    1fa5102c
        !hex    1fa61020
        !hex    1fb61420
        !hex    1fb81424
        !hex    1fc81824
        !hex    1fc71828
        !hex    1f971c28
        !hex    1f951c2c
        !hex    1e003034
        !hex    1e003438
        !hex    1e00383c
        !hex    1e003c30
        !hex    1f0000a0   ;faces
        !hex    5f6b6b6b
        !hex    1f6b6b6b
        !hex    9f6b6b6b
        !hex    df6b6b6b
        !hex    5f00a000
        !hex    1fa00000
        !hex    9fa00000
        !hex    1f00a000
        !hex    ff6b6b6b
        !hex    7f6b6b6b
        !hex    3f6b6b6b
        !hex    bf6b6b6b
        !hex    3f0000a0
; Escape capsule.
hull_escape
        !byte   $20
        !word   $0100
        !byte   $2c
        !byte   $44
        !byte   $1d
        !byte   $00
        !byte   $16
        !byte   $18
        !byte   $06
        !word   0
        !byte   $10
        !byte   $08
        !byte   17
        !byte   8
        !byte   $00
        !byte   $00
        !byte   $04
        !byte   %00000000
        !hex    0700249f1233 ;vertices
        !hex    070e0cff0233
        !hex    070e0cbf0133
        !hex    1500001f0122
        !hex    1f230004   ;edges
        !hex    1f030408
        !hex    1f01080c
        !hex    1f120c00
        !hex    1f130008
        !hex    1f020c04
        !hex    3f34007a   ;faces
        !hex    1f27671e
        !hex    5f27671e
        !hex    9f700000
; Plate, alloys.
hull_plate
        !byte   $80
        !word   $0064
        !byte   $2c
        !byte   $3c
        !byte   $15
        !byte   $00
        !byte   $0a
        !byte   $18
        !byte   $04
        !word   0
        !byte   $04
        !byte   $05
        !byte   16
        !byte   16
        !byte   $00
        !byte   $00
        !byte   $03
        !byte   %00000000
        !hex    0f1609ffffff ;vertices
        !hex    0f2609bfffff
        !hex    13200b14ffff
        !hex    0a2e0654ffff
        !hex    1fff0004   ;edges
        !hex    10ff0408
        !hex    14ff080c
        !hex    10ff0c00
        !hex    00000000   ;faces (always visible)
; Cargo canister.
hull_cargo
        !byte   $00
        !word   $0190
        !byte   $50
        !byte   $8c
        !byte   $35
        !byte   $00
        !byte   $12
        !byte   $3c
        !byte   $0f
        !word   0
        !byte   $1c
        !byte   $0c
        !byte   17
        !byte   15
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00000000
        !hex    1810001f1055 ;vertices
        !hex    18050f1f1022
        !hex    180d095f2033
        !hex    180d097f3044
        !hex    18050f3f4055
        !hex    1810009f5166
        !hex    18050f9f2166
        !hex    180d09df3266
        !hex    180d09ff4366
        !hex    18050fbf5466
        !hex    1f100004   ;edges
        !hex    1f200408
        !hex    1f30080c
        !hex    1f400c10
        !hex    1f500010
        !hex    1f510014
        !hex    1f210418
        !hex    1f32081c
        !hex    1f430c20
        !hex    1f541024
        !hex    1f611418
        !hex    1f62181c
        !hex    1f631c20
        !hex    1f642024
        !hex    1f652414
        !hex    1f600000   ;faces
        !hex    1f00291e
        !hex    5f001230
        !hex    5f003300
        !hex    7f001230
        !hex    3f00291e
        !hex    9f600000
; Boulder.
hull_boulder
        !byte   $00
        !word   $0384
        !byte   $3e
        !byte   $7a
        !byte   $31
        !byte   $00
        !byte   $0e
        !byte   $2a
        !byte   $0f
        !word   1          ;bounty (1)
        !byte   $28
        !byte   $14
        !byte   20
        !byte   30
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00000000
        !hex    12250bbf0159 ;vertices
        !hex    1e070c1f1256
        !hex    1c070c7f2367
        !hex    0200273f3478
        !hex    1c221ebf0489
        !hex    050a0d5fffff
        !hex    14111e3fffff
        !hex    1f150004   ;edges
        !hex    1f260408
        !hex    1f37080c
        !hex    1f480c10
        !hex    1f091000
        !hex    1f010014
        !hex    1f120414
        !hex    1f230814
        !hex    1f340c14
        !hex    1f041014
        !hex    1f590018
        !hex    1f560418
        !hex    1f670818
        !hex    1f780c18
        !hex    1f891018
        !hex    df0f0308   ;faces
        !hex    9f070c1e
        !hex    5f202f18
        !hex    ff032707
        !hex    ff050401
        !hex    1f315408
        !hex    3f701515
        !hex    7f4c2352
        !hex    3f163889
        !hex    3f286e26
; Asteroid.
hull_asteroid
        !byte   $00
        !word   $1900
        !byte   $4a
        !byte   $9e
        !byte   $45
        !byte   $00
        !byte   $22
        !byte   $36
        !byte   $15
        !word   5          ;bounty (5)
        !byte   $38
        !byte   $32
        !byte   60
        !byte   30
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00000000
        !hex    0050001fffff ;vertices
        !hex    500a00dfffff
        !hex    0050005fffff
        !hex    4628005fffff
        !hex    3c32001f65dc
        !hex    32003c1fffff
        !hex    2800469f1032
        !hex    001e4b3fffff
        !hex    00323c7f98ba
        !hex    1f720004   ;edges
        !hex    1fd60010
        !hex    1fc50c10
        !hex    1fb4080c
        !hex    1fa30408
        !hex    1f320418
        !hex    1f310818
        !hex    1f410814
        !hex    1f101418
        !hex    1f600014
        !hex    1f540c14
        !hex    1f200018
        !hex    1f651014
        !hex    1fa80420
        !hex    1f87041c
        !hex    1fd7001c
        !hex    1fdc101c
        !hex    1fc90c1c
        !hex    1fb90c20
        !hex    1fba0820
        !hex    1f981c20
        !hex    1f094251   ;faces
        !hex    5f094251
        !hex    9f48401f
        !hex    df40492f
        !hex    5f2d4f41
        !hex    1f870f23
        !hex    1f264c46
        !hex    bf423b27
        !hex    ff430f50
        !hex    7f420e4b
        !hex    ff465028
        !hex    7f3a6633
        !hex    3f510943
        !hex    3f2f5e3f
; Splinter, rock.
; 
; Header seems broken (but matches C64 def)
;   edges offset = $fd78 --> A5E6 == escape pod edges
;   faces offset = $0044 --> A8B2 == hull_shuttle header
; 
; The data parses as valid, but the backface removal fails at some angles.
hull_splinter
        !byte   $b0
        !word   $0100
        !byte   $78        ;edge offset lo
        !byte   $44        ;face offset lo
        !byte   $1d
        !byte   $00
        !byte   $16
        !byte   $18        ;vertex count = 4 * 6
        !byte   $06        ;edge count = 6
        !word   0
        !byte   $10        ;face count = 4 * 4
        !byte   $08
        !byte   20
        !byte   10
        !byte   $fd        ;edge offset hi
        !byte   $00        ;face offset hi
        !byte   $05
        !byte   %00000000
        !hex    181910df1233 ;vertices
        !hex    000c0a3f0233
        !hex    0b06025f0133
        !hex    0c2a071f0122
        !hex    1f230004   ;looks like edge data (but not used)
        !hex    1f030408
        !hex    1f01080c
        !hex    1f120c00
; Shuttle.
hull_shuttle
        !byte   $0f
        !word   $09c4
        !byte   $86
        !byte   $fe
        !byte   $71
        !byte   $00
        !byte   $26
        !byte   $72
        !byte   $1e
        !word   0
        !byte   $34
        !byte   $16
        !byte   32
        !byte   8
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00000000
        !hex    0011175fffff ;vertices
        !hex    1100179fffff
        !hex    0012171fffff
        !hex    1200171fffff
        !hex    14141bff1239
        !hex    14141bbf3459
        !hex    14141b3f5679
        !hex    14141b7f1789
        !hex    05001b309999
        !hex    00021b709999
        !hex    05001ba99999
        !hex    00031b299999
        !hex    000923500abc
        !hex    03011f47ff02 ;v13 ($34)
        !hex    040b190801f4
        !hex    0b041908a13f
        !hex    03011fc76b23 ;v16 ($40)
        !hex    030b1988f8c0
        !hex    0a0419884f18
        !hex    1f020004   ;edges
        !hex    1f4a0408
        !hex    1f6b080c
        !hex    1f8c000c
        !hex    1f18001c
        !hex    18120010
        !hex    1f230410
        !hex    18340414
        !hex    1f450814
        !hex    0c560818
        !hex    1f670c18
        !hex    18780c1c
        !hex    1f391014
        !hex    1f591418
        !hex    1f79181c
        !hex    1f19101c
        !hex    100c0030
        !hex    100a0430
        !hex    10ab0830
        !hex    10bc0c30
        !hex    10992024
        !hex    07992428
        !hex    0999282c
        !hex    0799202c
        !hex    05bb3438   ;window 1
        !hex    08bb383c
        !hex    07bb343c
        !hex    05aa4044   ;window 2
        !hex    08aa4448
        !hex    07aa4048
        !hex    df373728   ;faces
        !hex    5f004a04
        !hex    df333317
        !hex    9f4a0004
        !hex    9f333317
        !hex    1f004a04
        !hex    1f333317
        !hex    1f4a0004
        !hex    5f333317
        !hex    3f00006b
        !hex    9f29295a   ;face 10
        !hex    1f29295a
        !hex    5f373728
; Transporter.
hull_transporter
        !byte   $00
        !word   $09c4
        !byte   $f2
        !byte   $aa
        !byte   $95
        !byte   $30
        !byte   $1a
        !byte   $de
        !byte   $2e
        !word   0
        !byte   $38
        !byte   $10
        !byte   32
        !byte   10
        !byte   $00
        !byte   $01
        !byte   $02
        !byte   %00000000
        !hex    000a1a3f0677 ;vertices
        !hex    19041abf0177
        !hex    1c031aff0122
        !hex    19081aff0233
        !hex    1a081a7f0344
        !hex    1d031a7f0455
        !hex    1a041a3f0566
        !hex    00060c13ffff
        !hex    1e010cdf1789
        !hex    21080cdf1239
        !hex    21080c5f345a
        !hex    1e010c5f56ab
        !hex    0b021edf89cd
        !hex    0d081edf39dd
        !hex    0e081e5f3add
        !hex    0b021e5fabcd
        !hex    050602877777 ;decoration vertices, face 7
        !hex    120302877777
        !hex    050707a77777
        !hex    120407a77777
        !hex    0b060ea77777
        !hex    0b0507a77777
        !hex    05070e276666 ;decoration vertices, face 6
        !hex    12040e276666
        !hex    0b0507276666
        !hex    050603276666
        !hex    120303276666
        !hex    0b0408076666
        !hex    0b0503276666
        !hex    10080de63333
        !hex    100810c63333
        !hex    11080d663333
        !hex    110810463333
        !hex    0d031ae80000
        !hex    0d031a680000
        !hex    09031a250000
        !hex    08031aa50000
        !hex    1f070004   ;edges
        !hex    1f010408
        !hex    1f02080c
        !hex    1f030c10
        !hex    1f041014
        !hex    1f051418
        !hex    1f060018
        !hex    1067001c
        !hex    1f170420
        !hex    0b120824
        !hex    1f230c24
        !hex    1f341028
        !hex    0b451428
        !hex    1f56182c
        !hex    11781c20
        !hex    11192024
        !hex    115a282c
        !hex    116b1c2c
        !hex    13bc1c3c
        !hex    138c1c30
        !hex    10892030
        !hex    1f392434
        !hex    1f3a2838
        !hex    10ab2c3c
        !hex    1f9d3034
        !hex    1f3d3438
        !hex    1fad383c
        !hex    1fcd303c
        !hex    07774044   ;deco: vertices 16-21, face 7
        !hex    0777484c   ; (5 edges, "IB")
        !hex    07774c50
        !hex    07774850
        !hex    07775054
        !hex    0766585c   ;deco: vertices 22-28, face 6
        !hex    07665c60   ; (7 edges, "DB")
        !hex    07666058
        !hex    07666468
        !hex    0766686c
        !hex    0766646c
        !hex    07666c70   ;(end of decorations)
        !hex    06337478
        !hex    06337c80
        !hex    08008488
        !hex    0500888c
        !hex    05008c90
        !hex    05009084
        !hex    3f000067   ;faces
        !hex    bf6f3007
        !hex    ff693f15
        !hex    5f002200
        !hex    7f693f15
        !hex    3f6f3007
        !hex    1f082003   ;face 6 normal [$08,$20,$03]
        !hex    9f082003   ;face 7 normal [-$08,$20,$03]
        !hex    9308220b
        !hex    9f4b204f
        !hex    1f4b204f
        !hex    1308220b
        !hex    1f002611
        !hex    1f000079
; Cobra MK-III.
hull_cobra_mk3
        !byte   $03
        !word   $2341
        !byte   $bc
        !byte   $54
        !byte   $9d
        !byte   $54        ;gun vertex (v21)
        !byte   $2a
        !byte   $a8        ;vertex count * 6
        !byte   $26        ;edge count
        !word   0
        !byte   $34        ;face count * 4
        !byte   $32
        !byte   150        ;health
        !byte   28         ;max speed
        !byte   $00
        !byte   $01
        !byte   $01
        !byte   %00010011  ;00LLLMMM
        !hex    20004c1fffff ;vertices
        !hex    20004c9fffff
        !hex    001a181fffff
        !hex    780308ff73aa
        !hex    7803087f84cc
        !hex    581028bfffff
        !hex    5810283fffff
        !hex    8008287f98cc
        !hex    800828ff97aa
        !hex    001a283f6599
        !hex    201828ffa9bb
        !hex    2018287fb9cc
        !hex    240828b49999
        !hex    080c28b49999
        !hex    080c28349999
        !hex    240828349999
        !hex    240c28749999
        !hex    081028749999
        !hex    081028f49999
        !hex    240c28f49999
        !hex    00004c06b0bb
        !hex    00005a1fb0bb
        !hex    500628e89999
        !hex    500628a89999
        !hex    580028a69999
        !hex    500628289999
        !hex    580028269999
        !hex    500628689999
        !hex    1fb00004   ;edges
        !hex    1fc40010
        !hex    1fa3040c
        !hex    1fa70c20
        !hex    1fc8101c
        !hex    1f98181c
        !hex    1f961824
        !hex    1f951424
        !hex    1f971420
        !hex    1f510814
        !hex    1f620818
        !hex    1f730c14
        !hex    1f841018
        !hex    1f100408
        !hex    1f200008
        !hex    1fa92028
        !hex    1fb9282c
        !hex    1fc91c2c
        !hex    1fba0428
        !hex    1fcb002c
        !hex    1d310414
        !hex    1d420018
        !hex    06b05054
        !hex    14993034
        !hex    1499484c
        !hex    1499383c
        !hex    14994044
        !hex    13993c40
        !hex    11993844
        !hex    13993448
        !hex    1399304c
        !hex    1e650824
        !hex    06995860
        !hex    06995c60
        !hex    0899585c
        !hex    06996468
        !hex    0699686c
        !hex    0899646c
        !hex    1f003e1f   ;faces
        !hex    9f123710
        !hex    1f123710
        !hex    9f10340e
        !hex    1f10340e
        !hex    9f0e2f00
        !hex    1f0e2f00
        !hex    9f3d6600
        !hex    1f3d6600
        !hex    3f000050
        !hex    df072a09
        !hex    5f001e06
        !hex    5f072a09
; Python.
hull_python
        !byte   $05
        !word   $1900
        !byte   $56
        !byte   $be
        !byte   $59
        !byte   $00
        !byte   $2a
        !byte   $42
        !byte   $1a
        !word   0
        !byte   $34
        !byte   $28
        !byte   250
        !byte   20
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   %00011011
        !hex    0000e01f1032 ;vertices
        !hex    0030301f1054
        !hex    6000103fffff
        !hex    600010bfffff
        !hex    0030203f5498
        !hex    0018703f89cc
        !hex    300070bfb8cc
        !hex    3000703fa9cc
        !hex    0030305f3276
        !hex    0030207f76ba
        !hex    0018707fbacc
        !hex    1f320020   ;edges
        !hex    1f20000c
        !hex    1f310008
        !hex    1f100004
        !hex    1f590810
        !hex    1f510408
        !hex    1f370820
        !hex    1f40040c
        !hex    1f620c20
        !hex    1fa70824
        !hex    1f840c10
        !hex    1fb60c24
        !hex    07880c14
        !hex    07bb0c28
        !hex    07990814
        !hex    07aa0828
        !hex    1fa9081c
        !hex    1fb80c18
        !hex    1fc81418
        !hex    1fc9141c
        !hex    1fac1c28
        !hex    1fcb1828
        !hex    1f981014
        !hex    1fba2428
        !hex    1f540410
        !hex    1f762024
        !hex    9f1b280b   ;faces
        !hex    1f1b280b
        !hex    df1b280b
        !hex    5f1b280b
        !hex    9f132600
        !hex    1f132600
        !hex    df132600
        !hex    5f132600
        !hex    bf19250b
        !hex    3f19250b
        !hex    7f19250b
        !hex    ff19250b
        !hex    3f000070
; Boa.
hull_boa
        !byte   $05
        !word   $1324
        !byte   $62
        !byte   $c2
        !byte   $5d
        !byte   $00
        !byte   $26
        !byte   $4e
        !byte   $18
        !word   0
        !byte   $34
        !byte   $28
        !byte   250
        !byte   24
        !byte   $00
        !byte   $00
        !byte   $00
        !byte   %00011100
        !hex    00005d1fffff ;vertices
        !hex    002857380233
        !hex    261963780144
        !hex    261963f81255
        !hex    26283bbf2369
        !hex    26283b3f036b
        !hex    3e00433f048b
        !hex    18414f7f148a
        !hex    18414fff157a
        !hex    3e0043bf2579
        !hex    00076b3602aa
        !hex    0d096b7601aa
        !hex    0d096bf612cc
        !hex    1f6b0014   ;edges
        !hex    1f8a001c
        !hex    1f790024
        !hex    1d690010
        !hex    1d8b0018
        !hex    1d7a0020
        !hex    1f361014
        !hex    1f0b1418
        !hex    1f48181c
        !hex    1f1a1c20
        !hex    1f572024
        !hex    1f291024
        !hex    18230410
        !hex    18030414
        !hex    18250c24
        !hex    18150c20
        !hex    18040818
        !hex    1814081c
        !hex    16020428
        !hex    1601082c
        !hex    16120c30
        !hex    0e0c282c
        !hex    0e1c2c30
        !hex    0e2c3028
        !hex    3f2b253c   ;faces
        !hex    7f002d59
        !hex    bf2b253c
        !hex    1f002800
        !hex    7f3e2014
        !hex    ff3e2014
        !hex    1f001706
        !hex    df170f09
        !hex    5f170f09
        !hex    9f1a0d0a
        !hex    5f001f0c
        !hex    1f1a0d0a
        !hex    2e00006b
; Anaconda.
hull_anaconda
        !byte   $07
        !word   $2710
        !byte   $6e
        !byte   $d2
        !byte   $5d
        !byte   $30
        !byte   $2e
        !byte   $5a
        !byte   $19
        !word   0
        !byte   $30
        !byte   $24
        !byte   252
        !byte   14
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00111111
        !hex    00073a3e0155 ;vertices
        !hex    2b0d25fe0122
        !hex    1a2f03fe0233
        !hex    1a2f037e0344
        !hex    2b0d257e0455
        !hex    0030313e1566
        !hex    450f0fbe1277
        !hex    2b2728df2388
        !hex    2b27285f3499
        !hex    450f0f3e45aa
        !hex    2b3517bfffff
        !hex    450120df2788
        !hex    0000fe1fffff
        !hex    4501205f49aa
        !hex    2b35173fffff
        !hex    1e010004   ;edges
        !hex    1e020408
        !hex    1e03080c
        !hex    1e040c10
        !hex    1e050010
        !hex    1d150014
        !hex    1d120418
        !hex    1d23081c
        !hex    1d340c20
        !hex    1d451024
        !hex    1e161428
        !hex    1e171828
        !hex    1e27182c
        !hex    1e281c2c
        !hex    1f381c30
        !hex    1f392030
        !hex    1e492034
        !hex    1e4a2434
        !hex    1e5a2438
        !hex    1e561438
        !hex    1e6b2838
        !hex    1f7b2830
        !hex    1f782c30
        !hex    1f9a3034
        !hex    1fab3038
        !hex    7e003331   ;faces
        !hex    be331257
        !hex    fe4d3913
        !hex    5f005a10
        !hex    7e4d3913
        !hex    3e331257
        !hex    3e006f14
        !hex    9f614818
        !hex    df6c4422
        !hex    5f6c4422
        !hex    1f614818
        !hex    1f005e12
; Crewed asteroid.
; 
; The vertices for this one match hull_asteroid, and it shares the actual
; edge/face data: hull_asteroid:
; 
;   edges at +$F7B2 = $A7E2 = asteroid edges
;   faces at +$F806 = $A836 = asteroid faces
; 
; The only differences are in the ship characteristics: this has 3x the health
; of an Asteroid, and has a pair of missiles.  The flags indicate that it has an
; escape pod and is a trader.
hull_asteroid2
        !byte   $07
        !word   $1900
        !byte   $b2
        !byte   $06
        !byte   $45
        !byte   $00
        !byte   $32
        !byte   $36
        !byte   $15
        !word   0
        !byte   $38
        !byte   $32
        !byte   180
        !byte   30
        !byte   $f7
        !byte   $f8
        !byte   $01
        !byte   %00000010
        !hex    0050001fffff ;vertices
        !hex    500a00dfffff
        !hex    0050005fffff
        !hex    4628005fffff
        !hex    3c32001f65dc
        !hex    32003c1fffff
        !hex    2800469f1032
        !hex    001e4b3fffff
        !hex    00323c7f98ba
; Viper.
hull_viper
        !byte   $00
        !word   $15f9
        !byte   $6e
        !byte   $be
        !byte   $51
        !byte   $00
        !byte   $2a
        !byte   $5a
        !byte   $14
        !word   0
        !byte   $1c
        !byte   $17
        !byte   140
        !byte   32
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00010001
        !hex    0000481f2143 ;vertices
        !hex    0010181e1022
        !hex    0010185e4355
        !hex    3000183f4266
LB0A6   !hex    300018bf3166
        !hex    1810187e5466
        !hex    181018fe3566
        !hex    1810183f2066
        !hex    181018bf1066
        !hex    200018b36666
        !hex    200018336666
        !hex    080818336666
        !hex    080818b36666
        !hex    080818f26666
        !hex    080818726666
        !hex    1f42000c   ;edges
        !hex    1e210004
        !hex    1e430008
        !hex    1f310010
        !hex    1e20041c
        !hex    1e100420
        !hex    1e540814
        !hex    1e530818
        !hex    1f601c20
        !hex    1e651418
        !hex    1f611020
        !hex    1e631018
        !hex    1f620c1c
        !hex    1e460c14
        !hex    13662430
        !hex    12662434
        !hex    1366282c
        !hex    12662838
        !hex    10662c38
        !hex    10663034
        !hex    1f002000   ;faces
        !hex    9f16210b
        !hex    1f16210b
        !hex    df16210b
        !hex    5f16210b
        !hex    5f002000
        !hex    3f000030
; Sidewinder.
hull_sidewinder
        !byte   $00
        !word   $1081
        !byte   $50
        !byte   $8c
        !byte   $41
        !byte   $00
        !byte   $1e
        !byte   $3c
        !byte   $0f
        !word   50         ;bounty (50)
        !byte   $1c
        !byte   $14
        !byte   70
        !byte   37
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00010000
        !hex    2000249f1054 ;vertices
        !hex    2000241f2065
        !hex    40001c3f3266
        !hex    40001cbf3144
        !hex    00101c3f1032
        !hex    00101c7f4365
        !hex    0c061caf3333
        !hex    0c061c2f3333
        !hex    0c061c6c3333
        !hex    0c061cec3333
        !hex    1f500004   ;edges
        !hex    1f620408
        !hex    1f200410
        !hex    1f100010
        !hex    1f41000c
        !hex    1f310c10
        !hex    1f320810
        !hex    1f430c14
        !hex    1f630814
        !hex    1f650414
        !hex    1f540014
        !hex    0f33181c
        !hex    0c331c20
        !hex    0c331824
        !hex    0c332024
        !hex    1f002008   ;faces
        !hex    9f0c2f06
        !hex    1f0c2f06
        !hex    3f000070
        !hex    df0c2f06
        !hex    5f002008
        !hex    5f0c2f06
; Mamba.
hull_mamba
        !byte   $01
        !word   $1324
        !byte   $aa
        !byte   $1a
        !byte   $61
        !byte   $00
        !byte   $22
        !byte   $96
        !byte   $1c
        !word   150        ;bounty (150)
        !byte   $14
        !byte   $19
        !byte   90
        !byte   30
        !byte   $00
        !byte   $01
        !byte   $02
        !byte   %00010010
        !hex    0000401f1032 ;vertices
        !hex    400820ff2044
        !hex    200820be2144
        !hex    2008203e3144
        !hex    4008207f3044
        !hex    0404108e1111
        !hex    0404100e1111
        !hex    08031c0d1111
        !hex    08031c8d1111
        !hex    140410d40000
        !hex    140410540000
        !hex    180714f40000
        !hex    100714f00000
        !hex    100714700000
        !hex    180714740000
        !hex    080420ad4444
        !hex    0804202d4444
        !hex    0804206e4444
        !hex    080420ee4444
        !hex    200420a74444
        !hex    200420274444
        !hex    240420674444
        !hex    240420e74444
        !hex    260020a54444
        !hex    260020254444
        !hex    1f200004   ;edges
        !hex    1f300010
        !hex    1f400410
        !hex    1e420408
        !hex    1e41080c
        !hex    1e430c10
        !hex    0e111418
        !hex    0c11181c
        !hex    0d111c20
        !hex    0c111420
        !hex    1400242c
        !hex    10002430
        !hex    10002834
        !hex    14002838
        !hex    0e003438
        !hex    0e002c30
        !hex    0d443c40
        !hex    0e444448
        !hex    0c443c48
        !hex    0c444044
        !hex    07445054
        !hex    05445060
        !hex    05445460
        !hex    07444c58
        !hex    05444c5c
        !hex    0544585c
        !hex    1e210008
        !hex    1e31000c
        !hex    5e001802   ;faces
        !hex    1e001802
        !hex    9e204010
        !hex    1e204010
        !hex    3e00007f
; Krait.
hull_krait
        !byte   $01
        !word   $0e10
        !byte   $7a
        !byte   $ce
        !byte   $59
        !byte   $00
        !byte   $12
        !byte   $66
        !byte   $15
        !word   100        ;bounty (100)
        !byte   $18
        !byte   $14
        !byte   80
        !byte   30
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00010000
        !hex    0000601f0123 ;vertices
        !hex    0012303f0345
        !hex    0012307f1245
        !hex    5a00033f0144
        !hex    5a0003bf2355
        !hex    5a00571e0111
        !hex    5a00579e2333
        !hex    000535090033
        !hex    000726060033
        !hex    120713893333
        !hex    120713090000
        !hex    120b27284444
        !hex    120b27684444
        !hex    24001e284444
        !hex    120b27a85555
        !hex    120b27e85555
        !hex    24001ea85555
        !hex    1f030004   ;edges
        !hex    1f120008
        !hex    1f01000c
        !hex    1f230010
        !hex    1f350410
        !hex    1f251008
        !hex    1f14080c
        !hex    1f040c04
        !hex    1e010c14
        !hex    1e231018
        !hex    08450408
        !hex    09001c28
        !hex    06002028
        !hex    09331c24
        !hex    06332024
        !hex    08442c34
        !hex    08443430
        !hex    0744302c
        !hex    0755383c
        !hex    08553c40
        !hex    08554038
        !hex    1f031803   ;faces
        !hex    5f031803
        !hex    df031803
        !hex    9f031803
        !hex    3f26004d
        !hex    bf26004d
; Adder.
hull_adder
        !byte   $00
        !word   $09c4
        !byte   $80
        !byte   $f4
        !byte   $65
        !byte   $00
        !byte   $16
        !byte   $6c
        !byte   $1d
        !word   40         ;bounty (40)
        !byte   $3c
        !byte   $14
        !byte   85
        !byte   24
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00010000
        !hex    1200289f01bc ;vertices
        !hex    1200281f0123
        !hex    1e00183f2345
        !hex    1e00283f4566
        !hex    1207287f567e
        !hex    120728ff78ae
        !hex    1e0028bf89aa
        !hex    1e0018bf9abc
        !hex    120728bf789d
        !hex    1207283f467d
        !hex    12070d9f09bd
        !hex    12070d1f024d
        !hex    12070ddf1ace
        !hex    12070d5f135e
        !hex    0b031d850000
        !hex    0b031d050000
        !hex    0b0418040000
        !hex    0b0418840000
        !hex    1f010004   ;edges
        !hex    07230408
        !hex    1f45080c
        !hex    1f560c10
        !hex    1f7e1014
        !hex    1f8a1418
        !hex    1f9a181c
        !hex    07bc1c00
        !hex    1f460c24
        !hex    1f7d2420
        !hex    1f892018
        !hex    1f0b0028
        !hex    1f9b1c28
        !hex    1f02042c
        !hex    1f24082c
        !hex    1f1c0030
        !hex    1fac1c30
        !hex    1f130434
        !hex    1f350834
        !hex    1f0d282c
        !hex    1f1e3034
        !hex    1f9d2028
        !hex    1f4d242c
        !hex    1fae1430
        !hex    1f5e1034
        !hex    0500383c
        !hex    03003c40
        !hex    04004044
        !hex    03004438
        !hex    1f00270a   ;faces
        !hex    5f00270a
        !hex    1f45320d
        !hex    5f45320d
        !hex    1f1e3400
        !hex    5f1e3400
        !hex    3f0000a0
        !hex    3f0000a0
        !hex    3f0000a0
        !hex    9f1e3400
        !hex    df1e3400
        !hex    9f45320d
        !hex    df45320d
        !hex    1f001c00
        !hex    5f001c00
; Gecko.
hull_gecko
        !byte   $00
        !word   $2649
        !byte   $5c
        !byte   $a0
        !byte   $45
        !byte   $00
        !byte   $1a
        !byte   $48
        !byte   $11
        !word   55         ;bounty (55)
        !byte   $24
        !byte   $12
        !byte   70
        !byte   30
        !byte   $00
        !byte   $00
        !byte   $03
        !byte   %00010000
        !hex    0a042fdf0345 ;vertices
        !hex    0a042f5f0123
        !hex    100817bf0567
        !hex    1008173f0178
        !hex    420003bf4566
        !hex    4200033f1288
        !hex    140e17ff3467
        !hex    140e177f2378
        !hex    080621d03333
        !hex    080621513333
        !hex    080d10f03333
        !hex    080d10713333
        !hex    1f030004   ;edges
        !hex    1f120414
        !hex    1f18140c
        !hex    1f070c08
        !hex    1f560810
        !hex    1f451000
        !hex    1f28141c
        !hex    1f371c18
        !hex    1f461810
        !hex    1d050008
        !hex    1e01040c
        !hex    1d340018
        !hex    1e23041c
        !hex    14670818
        !hex    14780c1c
        !hex    10332028
        !hex    1133242c
        !hex    1f001f05   ;faces
        !hex    1f042d08
        !hex    5f196c13
        !hex    5f00540c
        !hex    df196c13
        !hex    9f042d08
        !hex    bf5810d6
        !hex    3f0000bb
        !hex    3f5810d6
; Cobra MK-I.
hull_cobra_mk1
        !byte   $03
        !word   $2649
        !byte   $56
        !byte   $9e
        !byte   $49
        !byte   $28
        !byte   $1a
        !byte   $42
        !byte   $12
        !word   75         ;bounty (75)
        !byte   $28
        !byte   $13
        !byte   90
        !byte   26
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00010010
        !hex    120132df0123 ;vertices
        !hex    1201325f0145
        !hex    4200079f2388
        !hex    4200071f4599
        !hex    200c26bf2678
        !hex    200c263f4679
        !hex    360c26ff1378
        !hex    360c267f1579
        !hex    000c06340246
        !hex    000132420111
        !hex    00013c5f0111
        !hex    1f010400   ;edges
        !hex    1f230008
        !hex    1f380818
        !hex    1f17181c
        !hex    1f591c0c
        !hex    1f450c04
        !hex    1f280810
        !hex    1f671014
        !hex    1f49140c
        !hex    14020020
        !hex    14042004
        !hex    10261020
        !hex    10462014
        !hex    1f781018
        !hex    1f79141c
        !hex    14130018
        !hex    1415041c
        !hex    02012824
        !hex    1f00290a   ;faces
        !hex    5f001b03
        !hex    9f082e08
        !hex    df0c390c
        !hex    1f082e08
        !hex    5f0c390c
        !hex    1f003100
        !hex    3f00009a
        !hex    bf796f3e
        !hex    3f796f3e
; Worm.
hull_worm
        !byte   $00
        !word   $2649
        !byte   $50
        !byte   $90
        !byte   $4d
        !byte   $00
        !byte   $12
        !byte   $3c
        !byte   $10
        !word   0
        !byte   $20
        !byte   $13
        !byte   30
        !byte   23
        !byte   $00
        !byte   $00
        !byte   $03
        !byte   %00001000
        !hex    0a0a235f0277 ;vertices
        !hex    0a0a23df0377
        !hex    05060f1f0124
        !hex    05060f9f0135
        !hex    0f0a195f2477
        !hex    0f0a19df3577
        !hex    1a0a197f4677
        !hex    1a0a19ff5677
        !hex    080e193f1466
        !hex    080e19bf1566
        !hex    1f070004   ;edges
        !hex    1f370414
        !hex    1f57141c
        !hex    1f671c18
        !hex    1f471810
        !hex    1f271000
        !hex    1f020008
        !hex    1f03040c
        !hex    1f241008
        !hex    1f35140c
        !hex    1f140820
        !hex    1f462018
        !hex    1f150c24
        !hex    1f56241c
        !hex    1f01080c
        !hex    1f162024
        !hex    1f005846   ;faces
        !hex    1f00450e
        !hex    1f464223
        !hex    9f464223
        !hex    1f40310e
        !hex    9f40310e
        !hex    3f0000c8
        !hex    5f005000
; Cobra MK-III (pirate edition).  Vertices are same as regular version.  Has two
; missiles instead of 3.
; 
;   edges offset $f500 -> $ac7a -> hull_cobra_mk3 edges
;   faces offset $f598 -> $ad12 -> hull_cobra_mk3 faces
hull_cobra3_pir
        !byte   $01
        !word   $2341
        !byte   $00
        !byte   $98
        !byte   $9d
        !byte   $54
        !byte   $2a
        !byte   $a8
        !byte   $26
        !word   175        ;bounty (175)
        !byte   $34
        !byte   $32
        !byte   150
        !byte   28
        !byte   $f5
        !byte   $f5
        !byte   $01
        !byte   %00010010
        !hex    20004c1fffff ;vertices
        !hex    20004c9fffff
        !hex    001a181fffff
        !hex    780308ff73aa
        !hex    7803087f84cc
        !hex    581028bfffff
        !hex    5810283fffff
        !hex    8008287f98cc
        !hex    800828ff97aa
        !hex    001a283f6599
        !hex    201828ffa9bb
        !hex    2018287fb9cc
        !hex    240828b49999
        !hex    080c28b49999
        !hex    080c28349999
        !hex    240828349999
        !hex    240c28749999
        !hex    081028749999
        !hex    081028f49999
        !hex    240c28f49999
        !hex    00004c06b0bb
        !hex    00005a1fb0bb
        !hex    500628e89999
        !hex    500628a89999
        !hex    580028a69999
        !hex    500628289999
        !hex    580028269999
        !hex    500628689999
; Asp MK-II.
hull_asp_mk2
        !byte   $00
        !word   $0e10
        !byte   $86
        !byte   $f6
        !byte   $69
        !byte   $20
        !byte   $1a
        !byte   $72
        !byte   $1c
        !word   200        ;bounty (200)
        !byte   $30
        !byte   $28
        !byte   150
        !byte   40
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00101001
        !hex    001200560122 ;vertices
        !hex    00092d7f12bb
        !hex    2b002d3f16bb
        !hex    4503005f1679
        !hex    2b0e1c5f0177
        !hex    2b002dbf25bb
        !hex    450300df258a
        !hex    2b0e1cdf0288
        !hex    1a07495f0479
        !hex    1a0749df048a
        !hex    2b0e1c1f3469
        !hex    2b0e1c9f345a
        !hex    00092d3f356b
        !hex    11002daabbbb
        !hex    11002d29bbbb
        !hex    00042d6abbbb
        !hex    00042d28bbbb
        !hex    0007494a0404
        !hex    0007534a0404
        !hex    16120004   ;edges
        !hex    16010010
        !hex    1602001c
        !hex    1f1b0408
        !hex    1f16080c
        !hex    10790c20
        !hex    1f042024
        !hex    108a1824
        !hex    1f251418
        !hex    1f2b0414
        !hex    1f170c10
        !hex    1f071020
        !hex    1f28181c
        !hex    1f081c24
        !hex    1f6b0830
        !hex    1f5b1430
        !hex    16362830
        !hex    16352c30
        !hex    1634282c
        !hex    1f5a182c
        !hex    1f4a242c
        !hex    1f690c28
        !hex    1f492028
        !hex    0abb343c
        !hex    09bb3c38
        !hex    08bb3840
        !hex    08bb4034
        !hex    0a044844
        !hex    5f002305   ;faces
        !hex    7f082607
        !hex    ff082607
        !hex    36001801
        !hex    1f002b13
        !hex    bf061c02
        !hex    3f061c02
        !hex    5f3b401f
        !hex    df3b401f
        !hex    1f502e32
        !hex    9f502e32
        !hex    3f00005a
        !byte   $e7        ;?
        !byte   $33
        !byte   $53
        !byte   $08
; Python (pirate edition).  Vertices are same as regular version.
; 
;   edges offset $f43c -> $ad9c -> hull_python edges
;   faces offset $f4a4 -> $ae04 -> hull_python faces
hull_python_pir
        !byte   $02
        !word   $1900
        !byte   $3c
        !byte   $a4
        !byte   $59
        !byte   $00
        !byte   $2a
        !byte   $42
        !byte   $1a
        !word   200        ;bounty (200)
        !byte   $34
        !byte   $28
        !byte   250
        !byte   20
        !byte   $f4
        !byte   $f4
        !byte   $00
        !byte   %00011011
        !hex    0000e01f1032 ;vertices
        !hex    0030301f1054
        !hex    6000103fffff
        !hex    600010bfffff
        !hex    0030203f5498
        !hex    0018703f89cc
        !hex    300070bfb8cc
        !hex    3000703fa9cc
        !hex    0030305f3276
        !hex    0030207f76ba
        !hex    0018707fbacc
; Fer-de-lance.
hull_ferdelance
        !byte   $00
        !word   $0640
        !byte   $86
        !byte   $f2
        !byte   $6d
        !byte   $00
        !byte   $1a
        !byte   $72
        !byte   $1b
        !word   0
        !byte   $28
        !byte   $28
        !byte   160
        !byte   30
        !byte   $00
        !byte   $00
        !byte   $01
        !byte   %00010010
        !hex    000e6c5f0159 ;vertices
        !hex    280e04ff1299
        !hex    0c0e34ff2399
        !hex    0c0e347f3499
        !hex    280e047f4599
        !hex    280e04bc0126
        !hex    0c0234bc2367
        !hex    0c02343c3478
        !hex    280e043c0458
        !hex    0012142f0678
        !hex    030b61cb0000
        !hex    1a0812890000
        !hex    100e04ab0000
        !hex    030b614b0000
        !hex    1a0812090000
        !hex    100e042b0000
        !hex    000e146c9999
        !hex    0e0e2ccc9999
        !hex    0e0e2c4c9999
        !hex    1f190004   ;edges
        !hex    1f290408
        !hex    1f39080c
        !hex    1f490c10
        !hex    1f590010
        !hex    1c010014
        !hex    1c261418
        !hex    1c37181c
        !hex    1c481c20
        !hex    1c050020
        !hex    0f061424
        !hex    0b671824
        !hex    0b781c24
        !hex    0f082024
        !hex    0e120414
        !hex    0e230818
        !hex    0e340c1c
        !hex    0e451020
        !hex    0800282c
        !hex    09002c30
        !hex    0b002830
        !hex    08003438
        !hex    0900383c
        !hex    0b00343c
        !hex    0c994044
        !hex    0c994048
        !hex    08994448
        !hex    1c001806   ;faces
        !hex    9f440018
        !hex    bf3f0025
        !hex    3f000068
        !hex    3f3f0025
        !hex    1f440018
        !hex    bc0c2e13
        !hex    3c002d16
        !hex    3c0c2e13
        !hex    5f001c00
; Moray.
hull_moray
        !byte   $01
        !word   $0384
        !byte   $68
        !byte   $b4
        !byte   $49
        !byte   $00
        !byte   $1a
        !byte   $54
        !byte   $13
        !word   50         ;bounty (50)
        !byte   $24
        !byte   $28
        !byte   100
        !byte   25
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00010000
        !hex    0f00411f0278 ;vertices
        !hex    0f00419f0167
        !hex    00122831ffff
        !hex    3c00009f1366
        !hex    3c00001f2588
        !hex    1e1b0a784578
        !hex    1e1b0af83467
        !hex    090419e74444
        !hex    090419674444
        !hex    001210674444
        !hex    0d0331050000
        !hex    060041050000
        !hex    0d0331850000
        !hex    060041850000
        !hex    1f070004   ;edges
        !hex    1f16040c
        !hex    18360c18
        !hex    18471418
        !hex    18581014
        !hex    1f280010
        !hex    0f670418
        !hex    0f780014
        !hex    0f020008
        !hex    0f010408
        !hex    1113080c
        !hex    11250810
        !hex    0d450814
        !hex    0d340818
        !hex    05441c20
        !hex    07441c24
        !hex    07442024
        !hex    0500282c
        !hex    05003034
        !hex    1f002b07   ;faces
        !hex    9f0a3107
        !hex    1f0a3107
        !hex    f83b1c65
        !hex    7800344e
        !hex    783b1c65
        !hex    df486332
        !hex    5f00531e
        !hex    5f486332
; Thargoid.
hull_thargoid
        !byte   $00
        !word   $2649
        !byte   $8c
        !byte   $f4
        !byte   $69
        !byte   $3c
        !byte   $26
        !byte   $78
        !byte   $1a
        !word   500        ;bounty (500)
        !byte   $28
        !byte   $37
        !byte   240
        !byte   39
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00010110
        !hex    2030305f4088 ;vertices
        !hex    2044005f1044
        !hex    2030307f2144
        !hex    2000443f3244
        !hex    2030303f4355
        !hex    2044001f5466
        !hex    2030301f6477
        !hex    2000441f7488
        !hex    187474df8099
        !hex    18a400df1099
        !hex    187474ff2199
        !hex    1800a4bf3299
        !hex    187474bf5399
        !hex    18a4009f6599
        !hex    1874749f7699
        !hex    1800a49f8799
        !hex    1840509e9999
        !hex    184050be9999
        !hex    184050fe9999
        !hex    184050de9999
        !hex    1f84001c   ;edges
        !hex    1f400004
        !hex    1f410408
        !hex    1f42080c
        !hex    1f430c10
        !hex    1f541014
        !hex    1f641418
        !hex    1f74181c
        !hex    1f800020
        !hex    1f100424
        !hex    1f210828
        !hex    1f320c2c
        !hex    1f531030
        !hex    1f651434
        !hex    1f761838
        !hex    1f871c3c
        !hex    1f98203c
        !hex    1f902024
        !hex    1f912428
        !hex    1f92282c
        !hex    1f932c30
        !hex    1f953034
        !hex    1f963438
        !hex    1f97383c
        !hex    1e994044
        !hex    1e99484c
        !hex    5f673c19   ;faces
        !hex    7f673c19
        !hex    7f67193c
        !hex    3f67193c
        !hex    1f400000
        !hex    3f673c19
        !hex    1f673c19
        !hex    1f67193c
        !hex    5f67193c
        !hex    9f300000
; Thargon (Thargoid drone ships).
; 
;   edges offset $e9da -> $a69e -> hull_cargo edges
hull_thargon
        !byte   $f0
        !word   $0640
        !byte   $da
        !byte   $50
        !byte   $45
        !byte   $00
        !byte   $12
        !byte   $3c
        !byte   $0f
        !word   50         ;bounty (50)
        !byte   $1c
        !byte   $14
        !byte   20
        !byte   30
        !byte   $e9
        !byte   $00
        !byte   $02
        !byte   %00010000
        !hex    0900289f0155 ;vertices
        !hex    09260cdf0122
        !hex    091820ff0233
        !hex    091820bf0344
        !hex    09260c9f0455
        !hex    0900083f1566
        !hex    090a0f7f1266
        !hex    09061a7f2366
        !hex    09061a3f3466
        !hex    090a0f3f4566
        !hex    9f240000   ;faces
        !hex    5f140507
        !hex    7f2e2a0e
        !hex    3f240068
        !hex    3f2e2a0e
        !hex    1f140507
        !hex    1f240000
; Constrictor.
hull_constrictor
        !byte   $03
        !word   $1081
        !byte   $7a
        !byte   $da
        !byte   $51
        !byte   $00
        !byte   $2e
        !byte   $66
        !byte   $18
        !word   0
        !byte   $28
        !byte   $2d
        !byte   252
        !byte   36
        !byte   $00
        !byte   $00
        !byte   $02
        !byte   %00110100
        !hex    1407505f0299 ;vertices
        !hex    140750df0199
        !hex    360728df1499
        !hex    360728ff4589
        !hex    140d28bf5688
        !hex    140d283f6788
        !hex    3607287f3789
        !hex    3607285f2399
        !hex    140d051fffff
        !hex    140d059fffff
        !hex    14073e529999
        !hex    14073ed29999
        !hex    190719729999
        !hex    190719f29999
        !hex    0f070f6a9999
        !hex    0f070fea9999
        !hex    000700409f01
        !hex    1f090004   ;edges
        !hex    1f190408
        !hex    1f010424
        !hex    1f020020
        !hex    1f29001c
        !hex    1f231c20
        !hex    1f140824
        !hex    1f49080c
        !hex    1f39181c
        !hex    1f371820
        !hex    1f671420
        !hex    1f561024
        !hex    1f450c24
        !hex    1f580c10
        !hex    1f681014
        !hex    1f781418
        !hex    1f890c18
        !hex    1f062024
        !hex    12992830
        !hex    05993038
        !hex    0a993828
        !hex    0a992c3c
        !hex    0599343c
        !hex    12992c34
        !hex    1f00370f   ;faces
        !hex    9f184b14
        !hex    1f184b14
        !hex    1f2c4b00
        !hex    9f2c4b00
        !hex    9f2c4b00
        !hex    1f003500
        !hex    1f2c4b00
        !hex    3f0000a0
        !hex    5f001b00
; Dodecahedral space station.
hull_dodo
        !byte   $00
        !word   $7e90
        !byte   $a4
        !byte   $2c
        !byte   $65
        !byte   $00
        !byte   $36
        !byte   $90
        !byte   $22
        !word   0
        !byte   $30
        !byte   $7d
        !byte   240
        !byte   0
        !byte   $00
        !byte   $01
        !byte   $00
        !byte   %00000000
        !hex    0096c41f0155 ;vertices
        !hex    8f2ec41f0122
        !hex    5879c45f0233
        !hex    5879c4df0344
        !hex    8f2ec49f0455
        !hex    00f32e1f1566
        !hex    e74b2e1f1277
        !hex    8fc42e5f2388
        !hex    8fc42edf3499
        !hex    e74b2e9f45aa
        !hex    8fc42e3f1677
        !hex    e74b2e7f2788
        !hex    00f32e7f3899
        !hex    e74b2eff49aa
        !hex    8fc42ebf56aa
        !hex    5879c43f67bb
        !hex    8f2ec47f78bb
        !hex    0096c47f89bb
        !hex    8f2ec4ff9abb
        !hex    5879c4bf6abb
        !hex    1020c49e0000
        !hex    1020c4de0000
        !hex    1020c4170000
        !hex    1020c4570000
        !hex    1f010004   ;edges
        !hex    1f020408
        !hex    1f03080c
        !hex    1f040c10
        !hex    1f051000
        !hex    1f161428
        !hex    1f172818
        !hex    1f27182c
        !hex    1f282c1c
        !hex    1f381c30
        !hex    1f393020
        !hex    1f492034
        !hex    1f4a3424
        !hex    1f5a2438
        !hex    1f563814
        !hex    1f7b3c40
        !hex    1f8b4044
        !hex    1f9b4448
        !hex    1fab484c
        !hex    1f6b4c3c
        !hex    1f150014
        !hex    1f120418
        !hex    1f23081c
        !hex    1f340c20
        !hex    1f451024
        !hex    1f67283c
        !hex    1f782c40
        !hex    1f893044
        !hex    1f9a3448
        !hex    1f6a384c
        !hex    1e005054
        !hex    1400545c
        !hex    17005c58
        !hex    14005850
        !hex    1f0000c4   ;faces
        !hex    1f678e58
        !hex    5fa93759
        !hex    5f00b058
        !hex    dfa93759
        !hex    9f678e58
        !hex    3f00b058
        !hex    3fa93759
        !hex    7f678e58
        !hex    ff678e58
        !hex    bfa93759
        !hex    3f0000c4
; This doesn't seem to be used.
        !hex    080803fe005ca06c737331009020b80000a99f5235009020c00000be9f523700
        !hex    9020cb000028a1485052009020e60000cc9f526166746572009020f40000d79f
        !hex    525832009021000000e29f525831009021040000ec9f52310090210c0000f69f
        !hex    526100902117000000a05236009021300000
