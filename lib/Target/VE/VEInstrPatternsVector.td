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


// Broadcast
// TODO actually all lanes > 0 are undef
def : Pat<(v256f64 (scalar_to_vector f64:$sy)),
          (VBRDf64r f64:$sy)>;

def : Pat<(v256f64 (vec_broadcast f64:$sy)), (VBRDf64r f64:$sy)>;
def : Pat<(v256i32 (vec_broadcast i32:$sy)), (VBRDi32r i32:$sy)>; // ???

def : Pat<(v256f64 (build_vector f64:$sy)),
          (VBRDf64r f64:$sy)>;


// Select

def : Pat<(v256f64 (select v4i64:$m, v256f64:$vy, v256f64:$vz)),
          (VMRGvm v256f64:$vz, v256f64:$vy, v4i64:$m)>;

def : Pat<(v512f32 (select v8i64:$m, v512f32:$vy, v512f32:$vz)),
          (VMRGpvm v512f32:$vz, v512f32:$vy, v8i64:$m)>;

// Sequence

def : Pat<(v256i32 (vec_seq (i32 1))), (VSEQlv)>;
def : Pat<(v512i32 (vec_seq (i32 1))), (VSEQpv)>;
def : Pat<(v256i64 (vec_seq (i32 1))), (VSEQv)>;
          

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


// Packed Single-Precision Arithmetic

def : Pat<(fadd v512f32:$vy, v512f32:$vz), (VFADpv v512f32:$vy, v512f32:$vz)>;
def : Pat<(fadd (vec_broadcast i64:$sy), v512f32:$vz), (VFADpr i64:$sy, v512f32:$vz)>;

def : Pat<(fsub v512f32:$vy, v512f32:$vz), (VFSBpv v512f32:$vy, v512f32:$vz)>;
def : Pat<(fsub (vec_broadcast i64:$sy), v512f32:$vz), (VFSBpr i64:$sy, v512f32:$vz)>;

def : Pat<(fmul v512f32:$vy, v512f32:$vz), (VFMPpv v512f32:$vy, v512f32:$vz)>;
def : Pat<(fmul (vec_broadcast i64:$sy), v512f32:$vz), (VFMPpr i64:$sy, v512f32:$vz)>;

def : Pat<(fdiv v512f32:$vy, v512f32:$vz), (VFDVpv v512f32:$vy, v512f32:$vz)>;
def : Pat<(fdiv (v512f32 (vec_broadcast i64:$sy)), v512f32:$vz), (VFDVpr i64:$sy, v512f32:$vz)>; 


// Integer Arithmetic

def : Pat<(add v512i32:$vx, v512i32:$vy), (VADDpv v512i32:$vx, v512i32:$vy)>;
def : Pat<(add v256i32:$vx, v256i32:$vy), (VADDlv v256i32:$vx, v256i32:$vy)>;
def : Pat<(add v256i64:$vx, v256i64:$vy), (VADXlv v256i64:$vx, v256i64:$vy)>;
