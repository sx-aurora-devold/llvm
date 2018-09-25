//===----------------------------------------------------------------------===//
// IR Vector Instruction Patterns
//===----------------------------------------------------------------------===//


// Memory Access

def : Pat<(v256f64 (load ADDRri:$addr)), 
          (v256f64 (VLDir 8, (LEAasx ADDRri:$addr)))>;

def : Pat<(v512f32 (load ADDRri:$addr)), 
          (v512f32 (VLDir 8, (LEAasx ADDRri:$addr)))>;

def : Pat<(store v256f64:$vx, ADDRri:$addr), 
          (VSTir v256f64:$vx, 8, (LEAasx ADDRri:$addr))>;

def : Pat<(store v512f32:$vx, ADDRri:$addr), 
          (VSTir v512f32:$vx, 8, (LEAasx ADDRri:$addr))>;


// Custom ISDs
// VEISD::VEC_SEQ - represents a vector sequence where the operand is the stride
// VEISD::VEC_BROADCAST - represents a vector splat of a scalar value into all vector lanes.

def vec_seq         : SDNode<"VEISD::VEC_SEQ",       SDTypeProfile<1, 1, [SDTCisVec<0>, SDTCisInt<1>]>>;
// FIXME: SDTCisEltOfVec<1, 0>]> breaks table-gen (type mismatch)
def vec_broadcast   : SDNode<"VEISD::VEC_BROADCAST", SDTypeProfile<1, 1, [SDTCisVec<0>]>>;

// Shuffle
// TODO

def : Pat<(f64 (extractelt v256f64:$vx, i64:$index)),
          (f64 (LVSf64r $vx, (EXTRACT_SUBREG $index, sub_i32)))>;

def : Pat<(i1 (extractelt v256i1:$vm, i64:$index)),
(i1
  (EXTRACT_SUBREG
    (SRLrr
      (ANDrr
        (SVMr (v256i1 $vm),
              (i64 (SRLri $index, 6))
        ),
        (ANDri $index, 63)
      ),
      (i32 (EXTRACT_SUBREG (ANDri $index, 63), sub_i32))
    ),
    sub_i1
  )
)>;

def : Pat<(insertelt v256f64:$vx, f64:$sx, i64:$index),
          (LSVr v256f64:$vx, (EXTRACT_SUBREG $index, sub_i32), $sx)>;

// Broadcast
def : Pat<(v256f64 (scalar_to_vector f64:$sy)), (VBRDf64r f64:$sy)>;

def : Pat<(v256i64 (vec_broadcast i64:$sy)), (VBRDr i64:$sy)>;
def : Pat<(v256f64 (vec_broadcast f64:$sy)), (VBRDf64r f64:$sy)>;
def : Pat<(v256i32 (vec_broadcast i32:$sy)), (VBRDi32r i32:$sy)>; 
def : Pat<(v256f32 (vec_broadcast f32:$sy)), (VBRDf32r f32:$sy)>;
// def : Pat<(v512f32 (vec_broadcast f32:$sy)), (VBRDpr f32:$sy)>; 
def : Pat<(v512i32 (vec_broadcast i64:$sy)), (VBRDpr i64:$sy)>; 

// Condition Code
def : Pat<(setcc v256i64:$vx, v256i64:$vy, CCSIOp:$cond),
          (v256i1 (VFMKv (icond2cc $cond), (VCMPlv v256i64:$vx, v256i64:$vy)))>;

def : Pat<(setcc v256f64:$vx, v256f64:$vy, CCSIOp:$cond),
          (v256i1 (VFMKv (fcond2cc $cond), (VCMPwv v256f64:$vx, v256f64:$vy)))>;

// (VFMKv (i32 uimm6:$cc), v256f64:$vz)

// def : Pat<(i32 (setcc i64:$LHS, i64:$RHS, CCSIOp:$cond)),
//           (EXTRACT_SUBREG
//               (CMOVLrm0 )>;
// 
// def : Pat<(setcc v256i64:$vx, v256i64:$vy, $cc),
//           (VFMKv (i32 uimm6:( $cc)), v256f64:$vz)>;

// Vector Select

// FIXME broken! (TODO legalize in custom lowering)
// def : Pat<(v256f64 (vselect v256i64:$m, v256f64:$vy, v256f64:$vz)), (VMRGvm v256f64:$vz, v256f64:$vy, (v4i64 $m))>;
def : Pat<(v256f64 (vselect v256i1:$m, v256f64:$vy, v256f64:$vz)), 
          (v256f64 (VMRGvm v256f64:$vz, v256f64:$vy, v256i1:$m))>; 
def : Pat<(v512f32 (vselect v512i1:$m, v512f32:$vy, v512f32:$vz)),
          (VMRGpvm v512f32:$vz, v512f32:$vy, v512i1:$m)>;

// Sequence

def : Pat<(v256i32 (vec_seq (i32 1))), (VSEQlv)>;
def : Pat<(v512i32 (vec_seq (i32 1))), (VSEQpv)>;
def : Pat<(v256i64 (vec_seq (i64 1))), (VSEQv)>;
          

// Format Conversions

// sint -> floating-point

def : Pat<(v256f64 (sint_to_fp v256i64:$vx)), (VFLTXv $vx)>;
def : Pat<(v256f64 (sint_to_fp v256i32:$vx)), (VFLTdv $vx)>;
def : Pat<(v256f32 (sint_to_fp v256i32:$vx)), (VFLTsv $vx)>;
def : Pat<(v512f32 (sint_to_fp v512i32:$vx)), (VFLTpv $vx)>;


// Double-Precision Arithmetic

def : Pat<(fadd (v256f64 (vec_broadcast f64:$sy)), v256f64:$vz), (VFADdr f64:$sy, v256f64:$vz)>; 
def : Pat<(fadd v256f64:$vy, v256f64:$vz), (VFADdv v256f64:$vy, v256f64:$vz)>;

def : Pat<(fsub (v256f64 (vec_broadcast f64:$sy)), v256f64:$vz), (VFSBdr f64:$sy, v256f64:$vz)>; 
def : Pat<(fsub v256f64:$vy, v256f64:$vz), (VFSBdv v256f64:$vy, v256f64:$vz)>;

def : Pat<(fmul (v256f64 (vec_broadcast f64:$sy)), v256f64:$vz), (VFMPdr f64:$sy, v256f64:$vz)>; 
def : Pat<(fmul v256f64:$vy, v256f64:$vz), (VFMPdv v256f64:$vy, v256f64:$vz)>;

def : Pat<(fdiv (v256f64 (vec_broadcast f64:$sy)), v256f64:$vz), (VFDVdr f64:$sy, v256f64:$vz)>; 
def : Pat<(fdiv v256f64:$vy, v256f64:$vz), (VFDVdv v256f64:$vy, v256f64:$vz)>;

def : Pat<(fma v256f64:$vz, v256f64:$vw, (v256f64 (fneg v256f64:$vy))), (VFMSBdv v256f64:$vy, v256f64:$vz, v256f64:$vw)>;

def : Pat<(fma (v256f64 (vec_broadcast f64:$sy)), v256f64:$vw, v256f64:$vy), (VFMADdr2 v256f64:$vy, f64:$sy, v256f64:$vw)>;
def : Pat<(fma v256f64:$vw, (v256f64 (vec_broadcast f64:$sy)), v256f64:$vy), (VFMADdr2 v256f64:$vy, f64:$sy, v256f64:$vw)>;
def : Pat<(fma v256f64:$vz, v256f64:$vw, (v256f64 (vec_broadcast f64:$sy))), (VFMADdr f64:$sy, v256f64:$vz, v256f64:$vw)>;
def : Pat<(fma v256f64:$vz, v256f64:$vw, v256f64:$vy), (VFMADdv v256f64:$vy, v256f64:$vz, v256f64:$vw)>;

def : Pat<(fneg v256f64:$vz), (VFSBdr (i64 0), v256f64:$vz)>;

// Packed Single-Precision Arithmetic

def : Pat<(fadd (vec_broadcast i64:$sy), v512f32:$vz), (VFADpr i64:$sy, v512f32:$vz)>;
def : Pat<(fadd v512f32:$vy, v512f32:$vz), (VFADpv v512f32:$vy, v512f32:$vz)>;

def : Pat<(fsub (vec_broadcast i64:$sy), v512f32:$vz), (VFSBpr i64:$sy, v512f32:$vz)>;
def : Pat<(fsub v512f32:$vy, v512f32:$vz), (VFSBpv v512f32:$vy, v512f32:$vz)>;

def : Pat<(fmul (vec_broadcast i64:$sy), v512f32:$vz), (VFMPpr i64:$sy, v512f32:$vz)>;
def : Pat<(fmul v512f32:$vy, v512f32:$vz), (VFMPpv v512f32:$vy, v512f32:$vz)>;

def : Pat<(fdiv (v512f32 (vec_broadcast i64:$sy)), v512f32:$vz), (VFDVpr i64:$sy, v512f32:$vz)>; 
def : Pat<(fdiv v512f32:$vy, v512f32:$vz), (VFDVpv v512f32:$vy, v512f32:$vz)>;

def : Pat<(fma v512f32:$vz, v512f32:$vw, (v512f32 (fneg v512f32:$vy))), (VFMSBpv v512f32:$vy, v512f32:$vz, v512f32:$vw)>;

def : Pat<(fma (v256f32 (vec_broadcast i64:$sy)), v256f32:$vw, v256f32:$vy), (VFMADpr2 v256f32:$vy, i64:$sy, v256f32:$vw)>;
def : Pat<(fma v256f32:$vw, (v256f32 (vec_broadcast i64:$sy)), v256f32:$vy), (VFMADpr2 v256f32:$vy, i64:$sy, v256f32:$vw)>;
def : Pat<(fma v256f32:$vz, v256f32:$vw, (v256f32 (vec_broadcast i64:$sy))), (VFMADpr i64:$sy, v256f32:$vz, v256f32:$vw)>;
def : Pat<(fma v256f32:$vz, v256f32:$vw, v256f32:$vy), (VFMADpv v256f32:$vy, v256f32:$vz, v256f32:$vw)>;

def : Pat<(fneg v512f32:$vz), (VFSBpr (i64 0), v512f32:$vz)>;

// Integer Arithmetic

def : Pat<(add v512i32:$vx, v512i32:$vy), (VADDpv v512i32:$vx, v512i32:$vy)>;
def : Pat<(add v256i32:$vx, v256i32:$vy), (VADDlv v256i32:$vx, v256i32:$vy)>;
def : Pat<(add v256i64:$vx, v256i64:$vy), (VADXlv v256i64:$vx, v256i64:$vy)>;

def : Pat<(add v512i32:$vx, v512i32:$vy), (VADDpv v512i32:$vx, v512i32:$vy)>;
def : Pat<(add v256i32:$vx, v256i32:$vy), (VADDlv v256i32:$vx, v256i32:$vy)>;
def : Pat<(add v256i64:$vx, v256i64:$vy), (VADXlv v256i64:$vx, v256i64:$vy)>;

def : Pat<(add v512i32:$vx, v512i32:$vy), (VADDpv v512i32:$vx, v512i32:$vy)>;
def : Pat<(add v256i32:$vx, v256i32:$vy), (VADDlv v256i32:$vx, v256i32:$vy)>;
def : Pat<(add v256i64:$vx, v256i64:$vy), (VADXlv v256i64:$vx, v256i64:$vy)>;

// Logic
def : Pat<(and v256i64:$vx, v256i64:$vy), (VANDv v256i64:$vx, v256i64:$vy)>;
def : Pat<(or  v256i64:$vx, v256i64:$vy), (VORv v256i64:$vx, v256i64:$vy)>;
def : Pat<(xor v256i64:$vx, v256i64:$vy), (VXORv v256i64:$vx, v256i64:$vy)>;
