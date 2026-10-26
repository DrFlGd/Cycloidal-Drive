// Bearing catalog and motor frame tables for the pancake cycloidal gearbox.
// Included by cycloidal_gearbox.scad; not meant to be opened on its own.

// Vendor-neutral catalog boundary dimensions [bore, OD, width]. SKF-style ISO designations
// are used for the 618/619 families. 68xx/69xx shorthand from other suppliers is
// equivalent in boundary size but suffixes/seals must be verified before purchase.
function bearing_dims(code) =
    // Common shielded commodity bearings. Exact ZZ designations are retained in BOM output.
    code=="623ZZ" ? [3,10,4] :
    code=="624ZZ" ? [4,13,5] :
    code=="625ZZ" ? [5,16,5] :
    code=="626ZZ" ? [6,19,6] :
    code=="607ZZ" ? [7,19,6] :
    code=="608ZZ" ? [8,22,7] :
    code=="6000ZZ" ? [10,26,8] :
    code=="6813ZZ" ? [65,85,10] :
    code=="6814ZZ" ? [70,90,10] :
    // Compact miniature variants used for optional ring rollers.
    // VV / AVV entries use the sealed-width boundary dimensions of those designations.
    code=="685VV" ? [5,11,5] :
    code=="625"   ? [5,16,5] :
    code=="686AVV"? [6,13,5] :
    code=="688AVV"? [8,16,5] :
    code=="6800VV"? [10,19,5] :
    code=="6801VV"? [12,21,5] :
    code=="6802VV"? [15,24,5] :
    code=="6803VV"? [17,26,5] :
    code=="6804VV"? [20,32,7] :
    code=="6805VV"? [25,37,7] :
    code=="6806VV"? [30,42,7] :
    code=="624"   ? [4,13,5] :
    code=="605"   ? [5,14,5] :
    code=="626"   ? [6,19,6] :
    code=="608"   ? [8,22,7] :
    code=="6000"  ? [10,26,8] :
    code=="6001"  ? [12,28,8] :
    code=="61801" ? [12,21,5] :
    code=="61901" ? [12,24,6] :
    code=="61902" ? [15,28,7] :
    code=="61903" ? [17,30,7] :
    code=="61805" ? [25,37,7] :
    code=="61806" ? [30,42,7] :
    code=="61813" ? [65,85,10] :
    code=="61816" ? [80,100,10] :
    code=="61817" ? [85,110,13] :
    code=="61818" ? [90,115,13] :
    code=="61821" ? [105,130,13] :
    code=="61822" ? [110,140,16] :
    code=="61824" ? [120,150,16] :
    code=="61828" ? [140,175,18] : [0,0,0];
function bd(code)=bearing_dims(code)[0];
function bD(code)=bearing_dims(code)[1];
function bB(code)=bearing_dims(code)[2];

// Smallest-to-largest catalog pilot sizes used by the automatic input support selection.
function auto_pilot_code(n)= n==5?"625ZZ":n==6?"626ZZ":n==7?"607ZZ":n==8?"688AVV":n==10?"6800VV":n==12?"6801VV":n==15?"6802VV":n==17?"6803VV":n==20?"6804VV":n==25?"6805VV":n==30?"6806VV":"Custom";
function metric_journal(d)= d>=30?30:d>=25?25:d>=20?20:d>=17?17:d>=15?15:d>=12?12:d>=10?10:d>=8?8:d>=7?7:d>=6?6:5;
pilot_sizes=[30,25,20,17,15,12,10,8,7,6,5];

// NEMA frame tables: [frame side, mount spacing, pilot diameter, mount hole, shaft diameter].
function nema_frame(frame)=
    frame=="NEMA17" ? [42.30,31.00,22.00,3.50,5.00] :
    frame=="NEMA23" ? [57.15,47.14,38.10,5.20,6.35] :
    frame=="NEMA34" ? [86.00,69.60,73.00,8.50,12.70] : undef;
// Visualisation-only motor body length per frame.
function nema_body_length(frame)= frame=="NEMA17" ? 40 : frame=="NEMA23" ? 56 : frame=="NEMA34" ? 80 : 56;
